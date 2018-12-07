using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Data.Common;
using System.Data;

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
    public string[] SupportedFilterPredicates { get; set; }
    public List<ListValues> AvailableValues { get; set; }
  }

  public struct FilterOperator
  {
    public string OperatorID { get; set; }
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
    public IEnumerable<FilterColumn> FilterColumns { get; set; }
    public IEnumerable<FilterOperator> FilterOperators { get; set; }
    public IEnumerable<FilterParameterSet> SavedFilterSet { get; set; }
  }

  [Route("api/[controller]")]
  public class ValuesController : Controller
  {
    [HttpGet]
    public FiltersResultSet Get()
    {
      List<FilterColumn> rvColumns = new List<FilterColumn>();
      List<FilterOperator> rvOperators = new List<FilterOperator>();
      List<FilterParameterSet> rvFilters = new List<FilterParameterSet>();
      SqlConnection conn = new SqlConnection("Server=.;Database=DemoDB;Trusted_Connection=True;");
      conn.Open();

      using (SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.FilterPredicates", conn))
      {
        DataSet ds = new DataSet();
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        da.Fill(ds);

        foreach (DataRow item in ds.Tables[0].Rows)
        {
          rvOperators.Add(new FilterOperator()
          {
            isMultiValue = bool.Parse(item["IsMultiValue"].ToString()),
            OperatorID = item["PredicateID"].ToString(),
            Name = item["PredicateName"].ToString()
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

          rvColumns.Add(new FilterColumn()
          {
            ColumnID = int.Parse(item["ColumnID"].ToString()),
            DisplayName = item["ColumnDisplayName"].ToString(),
            SortEnabled = bool.Parse(item["ColumnSortEnabled"].ToString()),
            SupportedFilterPredicates = item["ColumnSupportedFilterPredicates"].ToString().Replace(" ", string.Empty).Split(','),
            AvailableValues = Values
          });
        }
      }

      conn.Close();
      return new FiltersResultSet() { FilterColumns = rvColumns, FilterOperators = rvOperators };
    }

    // GET api/<controller>/5
    [HttpGet("{id}")]
    public string Get(int id)
    {
      return "value";
    }

    // POST api/<controller>
    [HttpPost]
    public void Post([FromBody]string value)
    {
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
