using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Data.Common;
using System.Data;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace DemoWebApp
{
  public struct ListValues
  {
    public string value { get; set; }
    public string label { get; set; }
    public string group { get; set; }
  }

  public struct FilterColumn
  {
    public int ColumnID { get; set; }
    public string DisplayName { get; set; }
    public bool SortEnabled { get; set; }
    public string[] SupportedFilterOperators { get; set; }
    public List<ListValues> AvailableValues { get; set; }
  }

  public struct FilterOperator
  {
    public int OperatorID { get; set; }
    public bool isMultiValue { get; set; }
    public string Name { get; set; }
  }

  public struct FilterParameterSet
  {
    public int ColumnID { get; set; }
    public int OperatorID { get; set; }
    public string[] Value { get; set; }
  }

  public struct FiltersResultSet
  {
    public Dictionary<int, FilterColumn> FilterColumns { get; set; }
    public Dictionary<int, FilterOperator> FilterOperators { get; set; }
    public List<FilterParameterSet> SavedFilterSet { get; set; }
  }

  public struct SearchSubmitBody
  {
    public int PageSize { get; set; }
    public int PageOffset { get; set; }
    public List<FilterParameterSet> FilterSet { get; set; }
  }

  [Route("api/[controller]")]
  public class ValuesController : Controller
  {
    private readonly IConfiguration _configuration;
    private string _connectionString;

    public ValuesController(IConfiguration configuration)
    {
      _configuration = configuration;

      _connectionString = _configuration.GetConnectionString("DefaultConnection");
      Console.WriteLine(_connectionString);
    }
    
    [HttpGet]
    public FiltersResultSet Get()
    {
      Dictionary<int, FilterColumn> rvColumns = new Dictionary<int, FilterColumn>();
      Dictionary<int, FilterOperator> rvOperators = new Dictionary<int, FilterOperator>();
      List<FilterParameterSet> rvFilters = new List<FilterParameterSet>();
      SqlConnection conn = new SqlConnection(_connectionString);
      conn.Open();

      using (SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.FilterOperators", conn))
      {
        DataSet ds = new DataSet();
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(ds);

        foreach (DataRow item in ds.Tables[0].Rows)
        {
          rvOperators.Add(int.Parse(item["OperatorID"].ToString()), new FilterOperator()
          {
            isMultiValue = bool.Parse(item["IsMultiValue"].ToString()),
            OperatorID = int.Parse(item["OperatorID"].ToString()),
            Name = item["OperatorName"].ToString()
          });
        }
      }

      using (SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.FilterColumns WHERE ColumnFilterTableAlias = @Table", conn))
      {
        cmd.Parameters.AddWithValue("@Table", "Members");
        DataSet ds = new DataSet();
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(ds);

        foreach (DataRow item in ds.Tables[0].Rows)
        {
          List<ListValues> Values = new List<ListValues>();

          if (!string.IsNullOrEmpty(item["QueryForAvailableValues"].ToString()))
          {
            using (SqlCommand cmd2 = new SqlCommand(item["QueryForAvailableValues"].ToString(), conn))
            {
              DataSet ds2 = new DataSet();
              SqlDataAdapter da2 = new SqlDataAdapter(cmd2);
              da2.Fill(ds2);

              foreach (DataRow item2 in ds2.Tables[0].Rows)
              {
                Values.Add(new ListValues()
                {
                  value = item2["value"].ToString(),
                  label = item2["label"].ToString(),
                  group = item2["group"].ToString()
                });
              }
            }
          }

          rvColumns.Add(int.Parse(item["ColumnID"].ToString()), new FilterColumn()
          {
            ColumnID = int.Parse(item["ColumnID"].ToString()),
            DisplayName = item["ColumnDisplayName"].ToString(),
            SortEnabled = bool.Parse(item["ColumnSortEnabled"].ToString()),
            SupportedFilterOperators = item["ColumnSupportedFilterOperators"].ToString().Replace(" ", string.Empty).Split(','),
            AvailableValues = Values
          });
        }
      }

      conn.Close();

      // sample data
      rvFilters.Add(new FilterParameterSet() { ColumnID = 3, OperatorID = 1, Value = new string[] { "on" } });
      rvFilters.Add(new FilterParameterSet() { ColumnID = 3, OperatorID = 4, Value = new string[] { "a" } });
      rvFilters.Add(new FilterParameterSet() { ColumnID = 5, OperatorID = 11, Value = new string[] { "1", "2", "4" } });
      rvFilters.Add(new FilterParameterSet() { ColumnID = 9, OperatorID = 5, Value = new string[] { "2018-01-01" } });

      return new FiltersResultSet() { FilterColumns = rvColumns, FilterOperators = rvOperators, SavedFilterSet = rvFilters };
    }

    // GET api/<controller>/5
    [HttpGet("{id}")]
    public string Get(int id)
    {
      return "value";
    }

    // POST api/<controller>
    [HttpPost]
    public JsonResult Post([FromBody]SearchSubmitBody value)
    {
      JsonResult rv = Json(value.FilterSet);

      SqlConnection conn = new SqlConnection(_connectionString);
      conn.Open();

      using (SqlCommand cmd = new SqlCommand("dbo.FilterParseJsonParameters", conn))
      {
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("SourceTableAlias", "Members");
        cmd.Parameters.AddWithValue("PageSize", value.PageSize);
        cmd.Parameters.AddWithValue("Offset", value.PageOffset);
        cmd.Parameters.AddWithValue("JsonParams", JsonConvert.SerializeObject(Json(value.FilterSet).Value));
        //cmd.Parameters.AddWithValue("JsonOrdering", @"{ 'OrderingColumns': [{'columnId': 11, 'isAscending': 1},{ 'columnId': 5, 'isAscending': 1}] }");
        cmd.Parameters.Add(new SqlParameter("ParsedSQL", SqlDbType.NVarChar, -1) { Direction = ParameterDirection.Output });

        DataSet ds = new DataSet();
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(ds);

        rv = Json(ds);
      }

      conn.Close();

      return rv;
    }

    // PUT api/<controller>/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody]string value)
    {
    }

    // DELETE api/<controller>/5
    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
  }
}
