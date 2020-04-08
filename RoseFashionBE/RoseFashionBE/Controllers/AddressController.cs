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

        /*[HttpPost]
        public IHttpActionResult AddProvince()
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    string[] provinces = new string[] { "Cần Thơ", "Đà Nẵng", "Đắk Lắk", "Đăk Nông", "Điện Biên	",
                        "Đồng Nai","Đồng Tháp","Gia Lai","Hà Giang","Hà Nam","Hà Nội","Hà Tĩnh",
                    "Hải Dương","Hải Phòng","Hậu Giang","Hòa Bình","Hưng Yên","Khánh Hòa","Kiên Giang",
                    "Kon Tum","Lai Châu","Lạng Sơn","Lào Cai","Lâm Đồng","Long An",
                    "Nam Định","Nghệ An","Ninh Bình","Ninh Thuận","Phú Thọ","Phú Yên","Quảng Bình","Quảng Nam",
                    "Quảng Ngãi","Quảng Ninh","Quảng Trị","Sóc Trăng","Sơn La","Tây Ninh",
                    "Thái Bình","Thái Nguyên","Thanh Hóa","Thừa Thiên-Huế","Tiền Giang",
                    "TP Hồ Chí Minh","Trà Vinh","Tuyên Quang","Vĩnh Long","Vĩnh Phúc","Yên Bái"};
                    for (int i = 0; i < provinces.Length; i++)
                    {
                        string name = provinces[i];
                        string newid = "PV-" + (entity.Provinces.Count() + 1);
                        entity.Provinces.Add(new Province()
                        {
                            ProvinceID = newid,
                            ProvinceName = name,
                            DeliveryFee = 0
                        });
                        entity.SaveChanges();
                    }
                    return Ok();
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPut]
        public IHttpActionResult AddDistrict(string[] name, string pid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    for (int i = 0; i < name.Length; i++)
                    {
                        string newname = name[i];
                        string newid = "DT-" + (entity.Districts.Count() + 1);
                        entity.Districts.Add(new District()
                        {
                            DistrictID = newid,
                            ProvinceID = pid,
                            DistrictName = newname
                        });
                        entity.SaveChanges();
                    }
                    return Ok("OK");
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetName(string text, string pid)
        {
            try
            {
                List<string> namelist = new List<string>();
                int i = 0;
                while (i < text.Length)
                {
                    string temp = "";
                    int j = i;
                    while (text[j] != ',')
                    {
                        temp += text[j];
                        j++;
                    }
                    namelist.Add(temp);
                    i = j + 1;
                }
                using (var entity = new RoseFashionDBEntities())
                {
                    for (int k = 0; k < namelist.Count; k++)
                    {
                        string newname = namelist[k];
                        string newid = "DT-" + (entity.Districts.Count() + 1);
                        entity.Districts.Add(new District()
                        {
                            DistrictID = newid,
                            ProvinceID = pid,
                            DistrictName = newname
                        });
                        entity.SaveChanges();
                    }
                    return Ok("OK");
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }*/
    }
}
