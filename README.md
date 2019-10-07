# Dynamic Filters (a.k.a. FilterParseSearchParameters)

This repository includes an example front-end website, and a back-end database, for demonstrating fully-dynamic filtering capabilities (column, operator, value). Fully protected from SQL Injection, and based on "low-code development" principles.

It is the accompanying open-source project for the webinar [Advanced Dynamic Search Queries and How to Protect Them](https://eitanblumin.com/2019/01/08/upcoming-webinar-advanced-dynamic-search-queries-and-how-to-protect-them/).

This is an enhanced version of **FilterParseXMLParameters** which is available here:

[https://eitanblumin.com/2018/10/28/dynamic-search-queries-versus-sql-injection](https://eitanblumin.com/2018/10/28/dynamic-search-queries-versus-sql-injection/)

The new version introduces two new methods for dynamically parsing filter sets:
1. Json parameter sets.
2. Table-Valued Parameters.

As mentioned above, this repository also includes a fully-functional demo web app, implemented in ASP.NET Core MVC + AngularJS, to demonstrate the intended functionality on the front-end side.

## Prerequisites

- [.NET Core Installed](https://www.microsoft.com/net/core#windowscmd)
- [Microsoft SQL Server 2016 version or newer](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- [Microsoft Visual Studio 2017 Community or newer](https://www.visualstudio.com/downloads/)
- [SQL Server Data Tools (SSDT) for Visual Studio](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt)

## Installation & Setup

1. Start by [forking or cloning this repository](https://github.com/EitanBlumin/DynamicFilters) to your computer, and opening the DynamicFilters solution in Visual Studio.
2. Creating the Database: Do one of the following:
	- Open the [DemoDB_Create.sql](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB_Publish/DemoDB_Create.sql) script file and run it in your local SQL Server instance (must be **in SQLCMD mode**). Or:
	- Manually publish the [DemoDB.dacpac](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB_Publish/DemoDB.dacpac) file into your database. Or:
	- Open the DemoDB database project, and **publish** it to your local SQL Server instance.
3. Optionally: Change the connection string in `\DemoWebClient\appsettings.json` in case you're not using default settings (localhost server, DemoDB database, Windows Authentication).
4. Whenever you want to run the app: Right click on the `\DemoWebClient\runme.bat` executable and **Run it as Administrator**.
5. The web app should now be available at [http://localhost:5000](http://localhost:5000) (you may also build the app from the web project, and the address would be [http://localhost:61907](http://localhost:61907) )

## Presentation

This GitHub repository also includes an accompanying Powerpoint presentation, available here:

- [DynamicFilters_Presentation_Eng.pptx](https://github.com/EitanBlumin/DynamicFilters/blob/master/DynamicFilters_Presentation_Eng.pptx)

## Main Stored Procedures

The "FilterParse" stored procedures are the "main engine" for this solution. They can be found here:

- [FilterParseTVPParameters](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseTVPParameters.sql)
- [FilterParseJsonParameters](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseJsonParameters_Standalone.sql)
- [FilterParseXmlParameters](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseXmlParameters_Standalone.sql)

The last two procedures (for Json and Xml) also have versions which can be used as "wrappers" that relay the information into the first procedure (using Table Valued Parameters). This should improve performance for scenarios involving large filter sets:

- [FilterParseJsonParameters (wrapper)](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseJsonParameters.sql)
- [FilterParseXmlParameters (wrapper)](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseXmlParameters.sql)

Additionally, these two procedures also have alternate versions that implement "Encapsulation" using an additional inner `sp_executesql` command, which should improve performance issues caused by bad parameter sniffing:

- [FilterParseJsonParameters (with encapsulation)](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseJsonParameters_with_Encapsulation.sql)
- [FilterParseXmlParameters (with encapsulation)](https://github.com/EitanBlumin/DynamicFilters/blob/master/DemoDB/Stored%20Procedures/dbo.FilterParseXmlParameters_with_Encapsulation.sql)

