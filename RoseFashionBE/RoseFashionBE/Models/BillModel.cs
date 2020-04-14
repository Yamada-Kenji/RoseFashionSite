using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace RoseFashionBE.Models
{
    public class BillModel
    {
        public string BillID;
        public string CartID;
        public DateTime OrderDate;
        public DateTime DeliveryDate;
        public string ReceiverName;
        public string ReceiverPhone;
        public string DeliveryAddress;
        public string ProvinceName;
        public string DistrictName;
        public string DiscountCode;
        public long TotalPrice;
        public long DeliveryFee;
        public string Status;
    }
}