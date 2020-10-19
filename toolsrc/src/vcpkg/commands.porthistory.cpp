#include <vcpkg/base/json.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#include <vcpkg/commands.porthistory.h>
#include <vcpkg/help.h>
#include <vcpkg/paragraphs.h>
#include <vcpkg/tools.h>
#include <vcpkg/vcpkgcmdarguments.h>
#include <vcpkg/vcpkgpaths.h>
#include <vcpkg/versions.fetch.h>
#include <vcpkg/versions.h>

namespace vcpkg::Commands::PortHistory
{
    namespace
    {
        struct HistoryVersion
        {
            std::string port_name;
            std::string commit_id;
            std::string commit_date;
            std::string version_string;
            std::string version;
            std::string port_version;
            Versions::Scheme scheme;
        };

        const System::ExitCodeAndOutput run_git_command(const VcpkgPaths& paths, const std::string& cmd)
        {
            const fs::path& work_dir = paths.root;
            const fs::path dot_git_dir = paths.root / ".git";

            return vcpkg::Versions::Git::run_git_command(paths, dot_git_dir, work_dir, cmd);
        }

        const Versions::Scheme guess_version_scheme(const std::string& version_string)
        {
            if (Versions::Version::is_date(version_string))
            {
                return Versions::Scheme::Date;
            }

            if (Versions::Version::is_semver(version_string) || Versions::Version::is_semver_relaxed(version_string))
            {
                return Versions::Scheme::Relaxed;
            }

            return Versions::Scheme::String;
        }

        std::pair<std::string, std::string> clean_version_string(const std::string& version_string,
                                                                 int port_version,
                                                                 bool from_manifest)
        {
            // Manifest files and ports that use the `Port-Version` field are assumed to have a clean version string
            // already.
            if (from_manifest || port_version > 0)
            {
                return std::make_pair(version_string, std::to_string(port_version));
            }

            std::string clean_version = version_string;
            std::string clean_port_version = "0";

            const auto index = version_string.find_last_of('-');
            if (index != std::string::npos)
            {
                // Very lazy check to keep date versions untouched
                if (!Versions::Version::is_date_without_tags(version_string))
                {
                    clean_port_version = version_string.substr(index + 1);
                    clean_version.resize(index);
                }
            }

            return std::make_pair(clean_version, clean_port_version);
        }

        vcpkg::Optional<HistoryVersion> get_version_from_text(const std::string& text,
                                                              const std::string& commit_id,
                                                              const std::string& commit_date,
                                                              const std::string& port_name,
                                                              bool is_manifest)
        {
            auto res = Paragraphs::try_load_port_text(text, Strings::concat(commit_id, ":", port_name), is_manifest);
            if (const auto& maybe_scf = res.get())
            {
                if (const auto& scf = maybe_scf->get())
                {
                    // TODO: Get clean version name and port version
                    const auto version_string = scf->core_paragraph->version;
                    const auto clean_version =
                        clean_version_string(version_string, scf->core_paragraph->port_version, is_manifest);

                    // SCF to HistoryVersion
                    return HistoryVersion{port_name,
                                          commit_id,
                                          commit_date,
                                          version_string,
                                          clean_version.first,
                                          clean_version.second,
                                          guess_version_scheme(clean_version.first)};
                }
            }

            return nullopt;
        }

        vcpkg::Optional<HistoryVersion> get_version_from_commit(const VcpkgPaths& paths,
                                                                const std::string& commit_id,
                                                                const std::string& commit_date,
                                                                const std::string& port_name)
        {
            // Do we have a manifest file?
            const std::string manifest_cmd = Strings::format(R"(show %s:ports/%s/vcpkg.json)", commit_id, port_name);
            auto manifest_output = run_git_command(paths, manifest_cmd);
            if (manifest_output.exit_code == 0)
            {
                return get_version_from_text(manifest_output.output, commit_id, commit_date, port_name, true);
            }

            const std::string cmd = Strings::format(R"(show %s:ports/%s/CONTROL)", commit_id, port_name);
            auto control_output = run_git_command(paths, cmd);

            if (control_output.exit_code == 0)
            {
                return get_version_from_text(control_output.output, commit_id, commit_date, port_name, false);
            }

            return nullopt;
        }

        std::vector<HistoryVersion> read_versions_from_log(const VcpkgPaths& paths, const std::string& port_name)
        {
            // log --format="%H %cd" --date=short --left-only -- ports/{port_name}/.
            System::CmdLineBuilder builder;
            builder.string_arg("log");
            builder.string_arg("--format=%H %cd");
            builder.string_arg("--date=short");
            builder.string_arg("--left-only");
            builder.string_arg("--"); // Begin pathspec
            builder.string_arg(Strings::format("ports/%s/.", port_name));
            const auto output = run_git_command(paths, builder.extract());

            auto commits = Util::fmap(
                Strings::split(output.output, '\n'), [](const std::string& line) -> auto {
                    auto parts = Strings::split(line, ' ');
                    return std::make_pair(parts[0], parts[1]);
                });

            std::vector<HistoryVersion> ret;
            std::string last_version;
            for (auto&& commit_date_pair : commits)
            {
                auto maybe_version =
                    get_version_from_commit(paths, commit_date_pair.first, commit_date_pair.second, port_name);
                if (maybe_version.has_value())
                {
                    const auto version = maybe_version.value_or_exit(VCPKG_LINE_INFO);
                    if (last_version != version.version_string)
                    {
                        last_version = version.version_string;
                        ret.emplace_back(version);
                    }
                }
                // NOTE: Uncomment this code if you're looking for edge cases to patch in the generation.
                //       Otherwise, x-history simply skips "bad" versions, which is OK behavior.
                // else
                //{
                //    Checks::exit_with_message(VCPKG_LINE_INFO, "Failed to get version from %s:%s",
                //    commit_date_pair.first, port_name);
                //}
            }
            return ret;
        }
    }

    const CommandStructure COMMAND_STRUCTURE = {
        create_example_string("history <port>"),
        1,
        1,
        {},
        nullptr,
    };

    void perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths)
    {
        const ParsedArguments options = args.parse_arguments(COMMAND_STRUCTURE);

        std::string port_name = args.command_arguments.at(0);
        std::vector<HistoryVersion> versions = read_versions_from_log(paths, port_name);

        if (args.output_json())
        {
            Json::Array versions_json;
            for (auto&& version : versions)
            {
                Json::Object object;
                object.insert("commit-id", Json::Value::string(version.commit_id));
                switch (version.scheme)
                {
                    case Versions::Scheme::Semver: // falls through
                    case Versions::Scheme::Relaxed:
                        object.insert("version", Json::Value::string(version.version));
                        break;
                    case Versions::Scheme::Date:
                        object.insert("version-date", Json::Value::string(version.version));
                        break;
                    case Versions::Scheme::String: // falls through
                    default: object.insert("version-string", Json::Value::string(version.version)); break;
                }
                object.insert("port-version", Json::Value::string(version.port_version));
                versions_json.push_back(std::move(object));
            }

            Json::Object root;
            root.insert("port", Json::Value::string(port_name));
            root.insert("versions", versions_json);

            auto json_string = Json::stringify(root, vcpkg::Json::JsonStyle::with_spaces(2));
            System::printf("%s\n", json_string);
        }
        else
        {
            System::print2("             version          date    vcpkg commit\n");
            for (auto&& version : versions)
            {
                System::printf("%20.20s    %s    %s\n", version.version_string, version.commit_date, version.commit_id);
            }
        }
        Checks::exit_success(VCPKG_LINE_INFO);
    }

    void PortHistoryCommand::perform_and_exit(const VcpkgCmdArguments& args, const VcpkgPaths& paths) const
    {
        PortHistory::perform_and_exit(args, paths);
    }
}
