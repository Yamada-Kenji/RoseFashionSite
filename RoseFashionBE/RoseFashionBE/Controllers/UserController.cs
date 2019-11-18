using RoseFashionBE.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.Web.Http;
using System.Net.Http;
using System.Web.Http.Cors;
using System.Security.Claims;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    public class UserController : ApiController
    {
        [HttpPost]
        public IHttpActionResult LoginWithModel(UserModel acc)
        {
            //nếu có truyền vào model thì thêm
            if (!ModelState.IsValid) return BadRequest("Invalid data.");
            try
            {
                var result = new UserModel();
                string pwrHash = GetMd5Hash(acc.Password);

                using (var ctx = new RoseFashionDBEntities())
                {
                    switch (acc.Role.ToLower())
                    {
                        case "admin":
                            result = ctx.Users
                                .Where(s => s.Username.ToLower().Equals(acc.Username.ToLower()) && s.Password.Equals(pwrHash))
                                .Select(s => new UserModel()
                                {
                                    Username = s.Username,
                                    Email = s.Email,
                                    Role = "admin"
                                }).FirstOrDefault();
                            break;
                        case "user":
                            result = ctx.Users
                                .Where(s => s.Username.ToLower().Equals(acc.Username.ToLower()) && s.Password.Equals(pwrHash))
                                .Select(s => new UserModel()
                                {
                                    Username = s.Username,
                                    Email = s.Email,
                                    Role = "user"
                                }).FirstOrDefault();
                            break;
                    
                        default: break;
                    }
                }

                if (result != null)
                {
                    
                    return Ok(result);
                }
                return BadRequest("Login fail.");
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        //Hash password MD5
        static string GetMd5Hash(string input) //source: docs.microsoft.com
        {
            MD5 md5Hash = MD5.Create();

            // Convert the input string to a byte array and compute the hash.
            byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

            // Create a new Stringbuilder to collect the bytes
            // and create a string.
            StringBuilder sBuilder = new StringBuilder();

            // Loop through each byte of the hashed data 
            // and format each one as a hexadecimal string.
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }

            // Return the hexadecimal string.
            return sBuilder.ToString();
        }

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

        public IHttpActionResult GetUserByID(string email)
        {
            UserModel result = null;
            using (var entity = new RoseFashionDBEntities())
            {
                    result = entity.Users.Where(ct => ct.Email == email)
                    .Select(ct => new UserModel
                    {
                        Email = ct.Email,
                        Username = ct.Username,
                        FullName = ct.FullName,
                        Address = ct.Address,
                        Phone = ct.Phone

                    }).FirstOrDefault<UserModel>();
                return Ok(result);
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
                        FullName = user.FullName,
                        Email = user.Email,
                        Password = Md5Encryption(user.Password),
                        Role = "User"
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

        [HttpPut]
        public IHttpActionResult EditAccount(UserModel account)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest("Invalid data.");
            }
            using (var entity = new RoseFashionDBEntities())
            {
                var Email = entity.Users.Where(c => c.Email.Equals(account.Email)).FirstOrDefault();
                if (Email != null)
                {
                    Email.Username = account.Username;
                    Email.FullName = account.FullName;
                    Email.Address = account.Address;
                    Email.Phone = account.Phone;
                    entity.SaveChanges();
                    return Ok("Edit account successfully!");
                }
                return NotFound();

            }
        }

    }
}
