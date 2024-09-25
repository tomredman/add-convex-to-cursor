![Static Badge](https://img.shields.io/badge/platform-convex-orange) ![Static Badge](https://img.shields.io/badge/script-bash-green) ![Static Badge](https://img.shields.io/badge/version-0.1-yellow) ![Static Badge](https://img.shields.io/badge/contributions-accepting-green)


# Cursor Convex Setup Script
![convex-logomark-512](https://github.com/user-attachments/assets/28071790-624c-47f3-b95d-9b749554b0b5 | width=64)

This Bash script automates the process of setting up Convex-related configurations for the Cursor editor on macOS. It enhances your Cursor environment with Convex-specific features, making it easier to work with Convex in your projects.

## Quickstart (aka stick to the script)

```bash
$ git clone https://github.com/tomredman/add-convex-to-cursor.git
$ cd add-convex-to-cursor
$ brew install jq # for shell-based JSON support
$ chmod +x add-convex-to-cursor-mac.sh
$ ./cursor_convex_setup.sh
```

## What does it do?

This script is purely for convenience.

It is exactly equivilent to:

1. Adding https://docs.convex.dev/ to your Cursor custom docs, found in Cursor Settings > Features > Docs
2. Adding `cursor.code-snippets` to Cursor's global snippet directory.

That's it!

To do this automatically, it will:

1. Prompt to close running instances of Cursor, if any
2. Add the docs URL and snippet file, if they don't already exist
3. Restart Cursor

## .cursorrules file

I've included the .cursorrules file, which is a clever attempt to make a lossless version of a natural language rules file, but in shorthand that LLM's can read. In theory. It can be found as part of this repo as `.cursorrules`

## Features

1. **Update Cursor's Personal Context**: Adds a Convex-related prompt to Cursor's AI context.
2. **Add Convex Documentation**: Includes Convex documentation in Cursor's personal docs for easy reference.
3. **Create Convex Code Snippets**: Adds useful Convex-related code snippets to Cursor.
4. **Manage Cursor Processes**: Safely terminates and restarts the Cursor application to apply changes.

## Prerequisites

- macOS operating system
- Cursor editor installed in the default location (`/Applications/Cursor.app`)
- `sqlite3` command-line tool (usually pre-installed on macOS)
- `jq` command-line JSON processor (can be installed via Homebrew: `brew install jq`)

## Usage

1. Download the script to your local machine.
2. Open Terminal and navigate to the directory containing the script.
3. Make the script executable:
   ```
   chmod +x cursor_convex_setup.sh
   ```
4. Run the script:
   ```
   ./cursor_convex_setup.sh
   ```
5. Follow the prompts in the terminal. The script will ask for confirmation before terminating Cursor processes.

## What the Script Does

1. Checks if Cursor is running and offers to terminate it.
2. Updates Cursor's personal context with a Convex-related prompt.
3. Adds Convex documentation to Cursor's personal docs.
4. Creates a new file with Convex-related code snippets for Cursor.
5. Restarts Cursor to apply the changes.

## Notes

- The script modifies Cursor's configuration files. It's recommended to backup your Cursor settings before running the script.
- If Cursor is running, the script will ask for permission to terminate it. This is necessary to apply the changes.
- The script assumes Cursor is installed in the default location. If you've installed Cursor elsewhere, you'll need to modify the `CURSOR_EXECUTABLE` variable in the script.

## Troubleshooting

- If the script fails to restart Cursor, try starting it manually.
- If you encounter any permission issues, ensure you have the necessary rights to modify files in Cursor's application support directory.

## Contributing

Feel free to fork this repository and submit pull requests with any enhancements or bug fixes. Issues and feature requests are also welcome!

## License

This script is provided "as is", without warranty of any kind. Use at your own risk.
