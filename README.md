# Dynamic Filters (i.e. FilterParseSearchParameters)

This repository includes an example front-end website, and a back-end database, for demonstrating fully-dynamic filtering capabilities (column, operator, value). Fully protected from SQL Injection.

This is an enhanced version of FilterParseXMLParameters which is available here:

https://eitanblumin.com/2018/10/28/dynamic-search-queries-versus-sql-injection/

The new version introduces two new methods for dynamically parsing filter sets:
1. Json parameter sets.
2. Table-Valued Parameters.

As mentioned above, this repository also includes a fully-functional demo web app, implemented in ASP.NET Core MVC + Angular 4, to demonstrate the intended functionality on the front-end side.

The demo web app was built based on the following tutorial: https://medium.com/@levifuller/building-an-angular-application-with-asp-net-core-in-visual-studio-2017-visualized-f4b163830eaa

## Prerequisites

- [Node.js Installed](https://nodejs.org/en/download/)
- [.NET Core Installed](https://www.microsoft.com/net/core#windowscmd)
- [Microsoft SQL Server 2016 version or newer](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- [Microsoft Visual Studio 2017 Community](https://www.visualstudio.com/downloads/)
- [SQL Server Data Tools (SSDT) for Visual Studio](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt)

## Installation & Setup

1. Start by forking or cloning the repository to your computer, and opening the FilterParseSearchParameters solution in Visual Studio.
2. Creating the Database: Do one of the following:
    - Open the DemoDB database project, and **publish** it to your local SQL Server instance. Or:
    - Open the "DemoDB Setup with data.sql" script file and run it in your local SQL Server instance (this will also generate data).
3. Open a command line with Administrator permissions and nagivate to the DemoWebApp folder.
4. Run the following commands in the command line (to install all angular dependencies and build the app):
```
npm install
ng build
```
5. Navigate to the DemoWebApp folder, edit the `run_core_server.bat` and `run_angular_app.bat` executables, and change the hard-coded paths within as needed, to point to the right path of DemoWebApp folder.
6. Right click on the `run_core_server.bat` executable and **Run it as Administrator**.
7. Similarly, right click on the `run_angular_app.bat` executable and **Run it as Administrator**.
8. The web app should now be available at http://localhost:4200
