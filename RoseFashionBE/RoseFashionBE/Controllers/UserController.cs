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
        public IHttpActionResult GetLogin(string username, string password)
        {
            //nếu có truyền vào model thì thêm
            //if (!ModelState.IsValid) return BadRequest("Invalid data.");
            try
            {
                int result = 0;
                string pwrHash = Md5Encryption(password);

                using (var ctx = new RoseFashionDBEntities())
                {
                   
                            result = ctx.Users
                                .Count(s => s.Username.ToLower().Equals(username.ToLower()) && s.Password.Equals(pwrHash));
                           
                }

                if (result == 1)
                {
                    return Ok(GenerateJwtToken(username));
                }
                return BadRequest("Login Failed");
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
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
        private string GenerateJwtToken(string username)
        {
            string serectKey = "ZmVlZGJhY2stc3lzdGVtLVNIQS0yNTYtc2VyZWN0LWtleQ=="; 
            int expireMinutes = 30;
            var symmetricKey = Convert.FromBase64String(serectKey);
            var tokenHandler = new JwtSecurityTokenHandler();

            var now = DateTime.UtcNow;
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.Name, username)
                }),

                Expires = now.AddMinutes(Convert.ToInt32(expireMinutes)),

                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(symmetricKey),
                    SecurityAlgorithms.HmacSha256Signature)
            };

            var stoken = tokenHandler.CreateToken(tokenDescriptor);
            var token = tokenHandler.WriteToken(stoken);

            return token;
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
