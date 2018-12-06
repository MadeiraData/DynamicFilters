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

  public struct FilterColumns
  {
    public int ColumnID { get; set; }
    public string DisplayName { get; set; }
    public bool SortEnabled { get; set; }
    public string[] SupportedFilterPredicates { get; set; }
    public List<ListValues> AvailableValues { get; set; }
  }

  [Route("api/[controller]")]
  public class ValuesController : Controller
  {
    [HttpGet]
    public IEnumerable<FilterColumns> Get()
    {
      List<FilterColumns> rv = new List<FilterColumns>();
      SqlConnection conn = new SqlConnection("Server=.;Database=DemoDB;Trusted_Connection=True;");
      conn.Open();

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

          rv.Add(new FilterColumns()
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
      return rv;
    }
  }
}
