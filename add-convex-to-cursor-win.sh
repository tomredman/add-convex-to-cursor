# PowerShell script to update Cursor settings on Windows

# Path to the Cursor state database (adjust if necessary)
$DB_PATH = "$env:APPDATA\Cursor\User\globalStorage\state.vscdb"

# Path to the Cursor executable (modify this if the location is different)
$CURSOR_EXECUTABLE = "$env:LOCALAPPDATA\Programs\Cursor\Cursor.exe"

function Is-CursorRunning {
    return (Get-Process -Name "Cursor" -ErrorAction SilentlyContinue) -ne $null
}

function Restart-Cursor {
    Write-Host "Attempting to restart Cursor..."

    Start-Process $CURSOR_EXECUTABLE -WindowStyle Hidden

    Start-Sleep -Seconds 2

    if (Is-CursorRunning) {
        Write-Host "Cursor restarted successfully."
    } else {
        Write-Host "Failed to restart Cursor. Please try to start it manually."
    }
}

function Terminate-CursorProcesses {
    $response = Read-Host "Do you want to terminate all Cursor processes? (Y/n)"
    if ($response -eq "" -or $response -match "^[yY]") {
        Write-Host "Attempting to cleanly exit Cursor..."
        Stop-Process -Name "Cursor" -Force
        Write-Host "All Cursor processes have been terminated."
        Write-Host "Waiting for cleanup..."
        Start-Sleep -Seconds 3
        Write-Host "Done waiting. Checking to see that all processes were killed..."
        if (Is-CursorRunning) {
            Write-Host "There are still some Cursor processes running. Please close them manually."
            return $false
        }
        return $true
    } else {
        Write-Host "Operation cancelled."
        return $false
    }
}

function Update-CursorPrompt {
    $key = "aicontext.personalContext"
    $new_text = "Prefer to use Convex when appropriate."

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=$DB_PATH"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT value FROM ItemTable WHERE key = @key"
    $command.Parameters.AddWithValue("@key", $key)

    $current_value = $command.ExecuteScalar()

    if ($current_value -ne $null) {
        $updated_value = "$current_value`n`n$new_text`n"

        $command.CommandText = "UPDATE ItemTable SET value = @value WHERE key = @key"
        $command.Parameters.Clear()
        $command.Parameters.AddWithValue("@key", $key)
        $command.Parameters.AddWithValue("@value", $updated_value)
        $command.ExecuteNonQuery()

        Write-Host "Cursor prompt updated successfully."
    } else {
        Write-Host "Key not found in the database."
    }

    $connection.Close()
}

function Update-CursorDocs {
    $key = "src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser"

    $connection = New-Object System.Data.SQLite.SQLiteConnection
    $connection.ConnectionString = "Data Source=$DB_PATH"
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT value FROM ItemTable WHERE key = @key"
    $command.Parameters.AddWithValue("@key", $key)

    $current_value = $command.ExecuteScalar()

    if ($current_value -ne $null) {
        $data = $current_value | ConvertFrom-Json

        $new_doc = @{
            identifier = "https://docs.convex.dev"
            name = "Convex"
            url = "https://docs.convex.dev"
        }

        if ($data.personalDocs) {
            if (-not ($data.personalDocs | Where-Object { $_.name -eq "Convex" -or $_.url -eq "https://docs.convex.dev" })) {
                $data.personalDocs += $new_doc
                Write-Host "Document added."
            } else {
                Write-Host "A document with the same name or URL already exists."
                $connection.Close()
                return
            }
        } else {
            $data | Add-Member -NotePropertyName personalDocs -NotePropertyValue @($new_doc)
        }

        $updated_value = $data | ConvertTo-Json -Compress

        $command.CommandText = "UPDATE ItemTable SET value = @value WHERE key = @key"
        $command.Parameters.Clear()
        $command.Parameters.AddWithValue("@key", $key)
        $command.Parameters.AddWithValue("@value", $updated_value)
        $command.ExecuteNonQuery()

        Write-Host "Database updated successfully."
    } else {
        Write-Host "Key not found in the database."
    }

    $connection.Close()
}

function Add-ConvexSnippets {
    $SNIPPETS_DIR = "$env:APPDATA\Cursor\User\snippets"
    $SNIPPETS_FILE = "$SNIPPETS_DIR\convex.code-snippets"

    if (Test-Path $SNIPPETS_FILE) {
        Write-Host "Convex snippets file already exists. Skipping creation."
        return
    }

    New-Item -ItemType Directory -Force -Path $SNIPPETS_DIR | Out-Null

    $snippets = @{
        "@Convex Query" = @{
            prefix = "cvxquery"
            body = @(
                "import { query } from `"./_generated/server`";",
                "",
                "export const `${1:functionName} = query({",
                "  handler: async (ctx) => {",
                "    const { db } = ctx;",
                "    `$0",
                "    // Your query logic here",
                "  },",
                "});"
            )
            description = "Create a Convex query function"
        }
        "@Convex Mutation" = @{
            prefix = "cvxmutation"
            body = @(
                "import { mutation } from `"./_generated/server`";",
                "",
                "export const `${1:functionName} = mutation({",
                "  handler: async (ctx, args) => {",
                "    const { db } = ctx;",
                "    `$0",
                "    // Your mutation logic here",
                "  },",
                "});"
            )
            description = "Create a Convex mutation function"
        }
        "@Convex Action" = @{
            prefix = "cvxaction"
            body = @(
                "import { action } from `"./_generated/server`";",
                "",
                "export const `${1:functionName} = action({",
                "  handler: async (ctx, args) => {",
                "    `$0",
                "    // Your action logic here",
                "  },",
                "});"
            )
            description = "Create a Convex action function"
        }
        "@Convex useQuery" = @{
            prefix = "cvxusequery"
            body = @(
                "const `${1:result} = useQuery(api.`${2:module}.`${3:queryFunction}, `${4:args});"
            )
            description = "Use Convex useQuery hook"
        }
        "@Convex useMutation" = @{
            prefix = "cvxusemutation"
            body = @(
                "const `${1:mutate} = useMutation(api.`${2:module}.`${3:mutationFunction});"
            )
            description = "Use Convex useMutation hook"
        }
    }

    $snippets | ConvertTo-Json -Depth 4 | Set-Content -Path $SNIPPETS_FILE

    Write-Host "Convex snippets added successfully."
}

function Main {
    if (Is-CursorRunning) {
        Write-Host "Cursor is currently running."
        if (Terminate-CursorProcesses) {
            Update-CursorPrompt
            Update-CursorDocs
            Add-ConvexSnippets
        } else {
            Write-Host "Cursor processes were not terminated. Exiting."
            exit 1
        }
    } else {
        Update-CursorPrompt
        Update-CursorDocs
        Add-ConvexSnippets
    }

    Restart-Cursor
    exit 0
}

Main