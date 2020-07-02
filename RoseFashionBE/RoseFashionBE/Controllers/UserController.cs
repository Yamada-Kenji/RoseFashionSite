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
using System.Net.Mail;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    [RoutePrefix("api/user")]
    public class UserController : ApiController
    {
        [HttpPost]
        [Route("login")]
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
                    
                        
                            result = ctx.Users
                                .Where(s => s.Email.ToLower().Equals(acc.Email.ToLower()) && s.Password.Equals(pwrHash))
                                .Select(s => new UserModel()
                                {
                                    UserID = s.UserID,
                                    FullName = s.FullName,
                                    Email = s.Email,
                                    Phone = s.Phone,
                                    Address = s.Address,
                                    Role = s.Role
                                }).FirstOrDefault();
                           
                    
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

        [HttpGet]
        public IHttpActionResult GetUserByID(string id)
        {
            UserModel result = null;
            using (var entity = new RoseFashionDBEntities())
            {
                    result = entity.Users.Where(ct => ct.UserID == id)
                    .Select(ct => new UserModel
                    {
                        UserID = id,
                        Email = ct.Email,
                        FullName = ct.FullName,
                        Address = ct.Address,
                        Province =ct.Province,
                        District = ct.District,
                        Phone = ct.Phone,
                        DOB = ct.DOB,
                        Role = ct.Role
                    }).FirstOrDefault<UserModel>();
                return Ok(result);
            }
        }

        [HttpGet]
        [Route("guest")]
        public IHttpActionResult CreateGuestUser()
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    //string guestname = "GUEST-" + (entity.Users.Count(u => u.Role == "guest") + 1);
                    string newid = Guid.NewGuid().ToString();
                    entity.Users.Add(new User()
                    {
                        UserID = newid,
                        FullName = "GUEST",
                        Password = Md5Encryption(newid),
                        Role = "guest"
                    });
                    entity.SaveChanges();

                    return Ok(newid);
                    //return Ok(guestname + "@gmail.com");
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
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
                        UserID = Guid.NewGuid().ToString(),
                        FullName = user.FullName,
                        Email = user.Email,
                        Password = Md5Encryption(user.Password),
                        Role = "user"
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

        

        /*private string GenerateJwtToken(string username)
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
        }*/

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
                    Email.FullName = account.FullName;
                    Email.Address = account.Address;
                    Email.Phone = account.Phone;
                    Email.Province = account.Province;
                    Email.District = account.District;
                    entity.SaveChanges();
                    return Ok("Edit account successfully!");
                }
                return NotFound();
   
            }
        }

        [HttpPost]
        [Route("recommendation")]
        public IHttpActionResult RunRecomendationAlgorithm()
        {         
            try
            {
                UserBaseCollaborativeFiltering();
                return Ok("Run Algorithm completed.");
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        private void UserBaseCollaborativeFiltering()
        {
            UserSimilarityCalculation();
            PredictUserRating();
        }

        //tính mức độ giống nhau giữa 2 user dựa vào những bộ phim mà cả 2 cùng đánh giá
        private double Cosine_Similarity(double[] v1, double[] v2)
        {
            if (v1.Length == 0) return 0;
            double v1xv2 = 0;               //kết quả nhân 2 vector v1 x v2
                                            //vd v1(a,b,c) và v2(d,e,f)
                                            //=> v1 x v2 = a*d + b*e + c*f 

            double v1_temp = 0;             //biến tạm dùng để lưu (a^2 + b^2 + c^2) đối vs vector 1
            double v2_temp = 0;

            for (int i = 0; i < v1.Length; i++)
            {
                v1xv2 += v1[i] * v2[i];
                v1_temp += Math.Pow(v1[i], 2);
                v2_temp += Math.Pow(v2[i], 2);
            }

            double v1_length = Math.Sqrt(v1_temp);      //độ dài của vector
            double v2_length = Math.Sqrt(v2_temp);

            double cosine = v1xv2 / (v1_length * v2_length);        //cosine = tích vô hướng của 2 vector / tích độ dài 2 vector

            return cosine;
        }


        //tính độ tương thích giữa các user
        private void UserSimilarityCalculation()
        {
            using(var entity = new RoseFashionDBEntities())
            {
                var userlist = entity.Users.Where(u => u.Role != "admin").ToList();
                for (int i = 0; i < userlist.Count - 1; i++)    //không cần xét user cuối
                {
                    string userid1 = userlist[i].UserID;
                    for (int j = i + 1; j < userlist.Count; j++)    //duyệt qua từng người phía sau user đang xét
                    {
                        string userid2 = userlist[j].UserID;

                        //lấy 2 vector của 2 user cần so sánh
                        // vector chỉ lấy rate value của những sp mà cả 2 cùng đánh giá
                        var vectors = entity.fn_GetTwoVetor(userid1, userid2).ToList();

                        double[] vector1 = new double[vectors.Count];
                        double[] vector2 = new double[vectors.Count];
                        for (int k = 0; k < vectors.Count; k++)
                        {
                            vector1[k] = (double)vectors[k].User1Rating;
                            vector2[k] = (double)vectors[k].User2Rating;
                        }

                        //tính và lưu lại độ tương thích của 2 user vào database
                        Similarity newrecord = new Similarity();
                        newrecord.UserID1 = userid1;
                        newrecord.UserID2 = userid2;
                        newrecord.SimilarityRate = Cosine_Similarity(vector1, vector2);

                        var existedrecord = entity.Similarities.FirstOrDefault(r =>
                            r.UserID1 == newrecord.UserID1 && r.UserID2 == newrecord.UserID2);

                        if (existedrecord != null)
                        {
                            existedrecord.SimilarityRate = newrecord.SimilarityRate;
                        }
                        else
                        {
                            entity.Similarities.Add(newrecord);
                        }
                        entity.SaveChanges();
                    }
                }
            }
        }


        //dự đoán số sao cho các sp mà user chưa mua
        private void PredictUserRating()
        {
            using(var entity = new RoseFashionDBEntities())
            {
                var userlist = entity.Users.Where(u => u.Role != "admin").ToList();
                foreach(User user in userlist)
                {
                    //tìm những sp mà 1 user chưa xem
                    var unratedproduct = entity.fn_GetUnRatedProduct(user.UserID).ToList();

                    //với mỗi sp 
                    foreach (string productid in unratedproduct)
                    {
                        //tìm ra tất cả những người đã đánh giá sp đó
                        // sau đó lọc lấy 10 người trong ds vừa tìm được có độ tương thích lớn nhất so với user đang cần gợi ý
                        var toprating = entity.fn_GetProductRatingFromTopSimilarUser(user.UserID, productid).ToList();

                        //nếu ko có user nào đánh giá cho sp này => ds rỗng
                        if (toprating.Count != 0)
                        {
                            //dự đoán rating của user cho sp đó
                            double sum = 0;
                            for (int i = 0; i < toprating.Count; i++)
                            {
                                sum += (double)toprating[i].Star;
                            }

                            double predictrating = sum / toprating.Count;   //tổng số sao / tổng số người đánh giá

                            //lưu kết quả dự đoán vào database
                            var oldrecord = entity.Recommendations.FirstOrDefault(r => 
                                r.UserID == user.UserID && r.ProductID == productid);
                            if (oldrecord != null)
                            {
                                oldrecord.PredictedStar = predictrating;
                            }
                            else
                            {
                                entity.Recommendations.Add(new Recommendation
                                {
                                    UserID = user.UserID,
                                    ProductID = productid,
                                    PredictedStar = predictrating
                                });
                            }
                            entity.SaveChanges();
                        }
                    }
                }
            }
        }

        //Socaial Logim
        [HttpPost]
        [Route("loginsocial")]
        public IHttpActionResult LoginWithID(UserModel acc)
        {
            //nếu có truyền vào model thì thêm
            if (!ModelState.IsValid) return BadRequest("Invalid data.");
            try
            {
                var result = new UserModel();
                using (var ctx = new RoseFashionDBEntities())
                {


                    result = ctx.Users
                        .Where(s => s.UserID.ToLower().Equals(acc.UserID.ToLower()))
                        .Select(s => new UserModel()
                        {
                            UserID = s.UserID,
                            FullName = s.FullName,
                            Email = s.Email,
                            Phone = s.Phone,
                            Address = s.Address,
                            Role = s.Role
                        }).FirstOrDefault();


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


        [HttpPost]
        [Route("registerSocial")]
        public IHttpActionResult RegisterSocial(UserModel user)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    int existedemail = entity.Users.Count(u => u.UserID.Equals(user.UserID));
                    if (existedemail < 1)
                    {
                        entity.Users.Add(new User()
                        {
                            UserID = user.UserID,
                            FullName = user.FullName,
                            Password = user.UserID,
                            Email = user.Email,
                            Role = "user"
                        });

                    }
                    entity.SaveChanges();
                    return Ok("Register successfully.");
                }

            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }
        //check email
        [HttpGet]
        public IHttpActionResult CheckEmail(string email)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    int checkemail = entity.Users.Count(u => u.Email.Equals(email));
                    
                    return Ok(checkemail);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }
        //change password
        [HttpPut]
        public IHttpActionResult ChangePass(UserModel account, string email)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest("Invalid data.");
            }
            string pwrHash = GetMd5Hash(account.Password);
            using (var entity = new RoseFashionDBEntities())
            {
                var Email = entity.Users.Where(c => c.Email.Equals(email)).FirstOrDefault();
                if (Email != null)
                {
                    Email.Password = account.Password;
                    entity.SaveChanges();
                    return Ok("Edit password successfully!");
                }
                return NotFound();

            }
        }

        //forgot pass
        [HttpGet]
        public IHttpActionResult getcode(string emailgetcode)
        {
            string validcode = "";
            Random rand = new Random();
            for (int i = 0; i < 5; i++)
            {
                validcode += rand.Next(0, 9).ToString();
            }

            
            try
            {
                MailMessage mail = new MailMessage("quynhdiemthinguyen@gmail.com", emailgetcode);
                SmtpClient client = new SmtpClient();
                client.Port = 587;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.UseDefaultCredentials = false;
                client.Credentials = new System.Net.NetworkCredential("quynhdiemthinguyen@gmail.com", "11121314151617");
                client.EnableSsl = true;
                client.Host = "smtp.gmail.com";
                mail.Subject = "This is your verification code";
                mail.Body = validcode + "\nLưu ý mã xác nhận chỉ tồn tại sau trong 5 phút, sau thời gian đó mã sẽ không còn tác dụng.";
                client.Send(mail);
                return Ok();

            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }

        }

    }
}
