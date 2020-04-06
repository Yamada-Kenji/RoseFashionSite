using RoseFashionBE.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Cors;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    public class AddressController : ApiController
    {
        public IHttpActionResult GetProvinces()
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Provinces
                        .Select(pv => new ProvinceModel
                        {
                            ProvinceID = pv.ProvinceID,
                            ProvinceName = pv.ProvinceName,
                            DeliveryFee = pv.DeliveryFee
                        }).ToList();
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        public IHttpActionResult GetDistrict(string pvid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Districts.Where(pv => pv.ProvinceID == pvid)
                        .Select(dt => new DistrictModel
                        {
                            DistrictID = dt.DistrictID,
                            ProvinceID = dt.ProvinceID,
                            DistrictName = dt.DistrictName
                        }).ToList();
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }
    }
}
