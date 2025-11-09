# company-utils

A minimal .NET class library packaged as a NuGet and published to Azure Artifacts.

## Projects
- `Company.Utils` (library)
- `Company.Utils.Tests` (xUnit tests)

## Build, Test, Pack locally
```bash
dotnet restore
dotnet build -c Release
dotnet test -c Release
dotnet pack Company.Utils/Company.Utils.csproj -c Release -o ./.artifacts
```

## Publish to Azure Artifacts (CI recommended)
Use the included `azure-pipelines.yml` in Azure DevOps and set your feed name.

### Local dev (optional)
```bash
dotnet nuget add source "https://pkgs.dev.azure.com/ORG/PROJECT/_packaging/team-utils/nuget/v3/index.json" --name team-utils
dotnet nuget push "./.artifacts/Company.Utils.1.0.0.nupkg" --source "team-utils" --api-key azdo --skip-duplicate
```
