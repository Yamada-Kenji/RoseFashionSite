using RoseFashionBE.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Web.Http;

namespace RoseFashionBE.Controllers
{
    public class UserController : ApiController
    {
        [HttpGet]
        public IHttpActionResult ShowAllUser()
        {
            using (var entity = new RoseFashionDBEntities())
            {
                return Ok(entity.Users.Select(u => new UserModel
                {
                    FullName = u.FullName,
                    Password = u.Password
                }).ToList());          
            }
        }

        [HttpPost]
        public IHttpActionResult Register(UserModel user)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    int existedemail = entity.Users.Count(u => u.Email.Equals(user.Email));
                    if (existedemail > 0) return BadRequest("Email already in use.");
                    entity.Users.Add(new User()
                    {
                        Username = user.Username,
                        Password = Md5Encryption(user.Password),
                        FullName = user.FullName,
                        Gender = user.Gender,
                        DOB = user.DOB,
                        Email = user.Email,
                        Address = user.Address,
                        Phone = user.Phone,
                        Role = user.Role,
                    });
                    entity.SaveChanges();
                    return Ok("Register successfully.");
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        string Md5Encryption(string password) //from docs.microsoft.com
        {
            MD5 md5hash = MD5.Create();

            // Convert the input string to a byte array and compute the hash.
            byte[] hasharray= md5hash.ComputeHash(Encoding.UTF8.GetBytes(password));

            // Create a new Stringbuilder to collect the bytes
            // and create a string.
            StringBuilder stringbuilder = new StringBuilder();

            for(int i = 0; i < hasharray.Length; i++)
            {
                stringbuilder.Append(hasharray[i].ToString("x2"));
            }

            // Return the hexadecimal string.
            return stringbuilder.ToString();
        }
    }
}
