using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using RoseFashionBE.Models;
using System.Web.Http.Cors;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    public class StatisticalController : ApiController
    {
        [HttpGet]
        public IHttpActionResult GetYears()
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var yearlist = entity.Bills.Select(c => c.OrderDate.Year).Distinct().ToList();
                    List<StatisticalModel> result = new List<StatisticalModel>();

                    for (int i = 0; i < yearlist.Count(); i++)
                    {
                        int year = yearlist[i];
                        var years = new StatisticalModel
                        {

                            Year = year
                        };
                        result.Add(years);
                    }
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetStatisticMonth(int year)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    List<StatisticalModel> result = new List<StatisticalModel>();
                    Double[] arrSum = new double[12];
                    int n = 0;
                    for (int i = 1; i < 13; i++)
                    {
                        double sum = 0;
                        try
                        {
                            sum = entity.Bills.Where(c => c.OrderDate.Year == year && c.OrderDate.Month == i).Sum(c => c.TotalPrice);
                        }
                        catch
                        {
                            sum = 0;
                        }
                        arrSum[n++] = sum;

                    }
                    return Ok(arrSum);
                }

            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }

        [HttpGet]
        public IHttpActionResult GetStatisticYear(int fromyear, int toyear)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {

                    //List<StatisticalModel> result = new List<StatisticalModel>();
                    int n = 0, j = 0;
                    if (fromyear > toyear)
                    {
                        int tem = fromyear;
                        fromyear = toyear;
                        toyear = tem;
                    }
                    for (int i = fromyear; i <= toyear; i++)
                    {
                        j++;
                    }
                    Double[] arrSum = new double[j];
                    for (int i = fromyear; i <= toyear; i++)
                    {
                        double sum = 0;
                        try
                        {
                            sum = entity.Bills.Where(c => c.OrderDate.Year == i).Sum(c => c.TotalPrice);
                        }
                        catch
                        {
                            sum = 0;
                        }

                        arrSum[n++] = sum;
                    }
                    //var statistic = new StatisticalModel
                    //{
                    //    StaticYear = arrSum
                    //};

                    //result.Add(statistic);
                    return Ok(arrSum);
                }

            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }
    }
}