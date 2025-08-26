# consumer-mvc

Minimal ASP.NET Core MVC app that **consumes** the `Company.Utils` package from Azure Artifacts
and displays the output on the home page.

## Configure feed
Edit `NuGet.config` and replace `ORG`, `PROJECT`, and `team-utils` with your values.

## Run
```bash
dotnet restore
dotnet run --project Consumer.App/Consumer.App.csproj
# open http://localhost:5000 or https://localhost:5001
```
