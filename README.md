# Dynamic Filters (a.k.a. FilterParseSearchParameters)

This repository includes an example front-end website, and a back-end database, for demonstrating fully-dynamic filtering capabilities (column, operator, value). Fully protected from SQL Injection, and based on "low-code development" principles.

It is the accompanying open-source project for the webinar [Advanced Dynamic Search Queries and How to Protect Them](https://eitanblumin.com/2019/01/08/upcoming-webinar-advanced-dynamic-search-queries-and-how-to-protect-them/).

This is an enhanced version of **FilterParseXMLParameters** which is available here:

[https://eitanblumin.com/2018/10/28/dynamic-search-queries-versus-sql-injection](https://eitanblumin.com/2018/10/28/dynamic-search-queries-versus-sql-injection/)

The new version introduces two new methods for dynamically parsing filter sets:
1. Json parameter sets.
2. Table-Valued Parameters.

As mentioned above, this repository also includes a fully-functional demo web app, implemented in ASP.NET Core MVC + Angular, to demonstrate the intended functionality on the front-end side.

The demo web app was built based on the following tutorial: [https://medium.com/@levifuller/building-an-angular-application-with-asp-net-core-in-visual-studio-2017-visualized-f4b163830eaa](https://medium.com/@levifuller/building-an-angular-application-with-asp-net-core-in-visual-studio-2017-visualized-f4b163830eaa)

## Prerequisites

- [Node.js Installed](https://nodejs.org/en/download/)
- [.NET Core Installed](https://www.microsoft.com/net/core#windowscmd)
- [Microsoft SQL Server 2016 version or newer](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- [Microsoft Visual Studio 2017 Community](https://www.visualstudio.com/downloads/)
- [SQL Server Data Tools (SSDT) for Visual Studio](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt)

## Installation & Setup

1. Start by [forking or cloning this repository](https://github.com/EitanBlumin/DynamicFilters) to your computer, and opening the DynamicFilters solution in Visual Studio.
2. Creating the Database: Do one of the following:
	- Open the [DemoDB_Create.sql](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB_Publish/DemoDB_Create.sql) script file and run it in your local SQL Server instance (must be **in SQLCMD mode**). Or:
	- Manually publish the [DemoDB.dacpac](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB_Publish/DemoDB.dacpac) file into your database. Or:
	- Open the DemoDB database project, and **publish** it to your local SQL Server instance.
3. Optionally: Change the connection string in `\DemoWebApp\appsettings.json` in case you're not using default settings (localhost server, DemoDB database, Windows Authentication).
4. This should only be done once: Right click on the `run_me_first_npm_init.bat` executable and **Run it as Administrator** , to install all angular dependencies and build the app.
5. Whenever you want to run the app: Right click on the `run_core_server.bat` executable and **Run it as Administrator**.
6. The web app should now be available at [http://localhost:26048/client.html](http://localhost:26048/client.html)

## Presentation

This GitHub repository also includes an accompanying Powerpoint presentation, available here:

- [DynamicFilters_Presentation_Eng.pptx](https://github.com/EitanBlumin/DynamicFilters/blob/master/DynamicFilters_Presentation_Eng.pptx)

## Main Stored Procedures

The "FilterParse" stored procedures are the "main engine" for this solution. They can be found here:

- [FilterParseJsonParameters](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseJsonParameters.sql)
- [FilterParseTVPParameters](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseTVPParameters.sql)
