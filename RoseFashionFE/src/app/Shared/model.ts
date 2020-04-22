export class UserModel{
    UserID: string;
    Password: string;
    FullName: string;
    Gender: string;
    DOB: Date;
    Email: string;
    Address: string;
    Phone: string;
    Role: string;

    constructor(){
        this.Role ='guest';
    }
}

export class ProductModel{
    ProductID: string;
    Name: string;
    Color: string;
    Size: string[] = [];
    CategoryID: string;
    Description: string;
    Quantity: number[] = [];
    Image: string;
    Price: number;
    DiscountPercent: number;
    SoldOut: boolean = false;
    ImportDate: Date;

    constructor(){
        this.ProductID = '';
        this.Name = '';
        this.Size = ['S', 'M', 'L', 'XL', 'XXL'];
        this.CategoryID = '';
        this.Quantity = [0, 0, 0, 0, 0];
        this.Image = '';
        this.Price = 0;
        this.DiscountPercent = 0;
        this.SoldOut = false;
        this.ImportDate = null;
    }
}

export class CategoryModel{
    CategoryID: string;
    Name: string;
    MainCategory: string;
}

export class CartModel{
    CartID: string;
    UserID: string;
    ProductID: string;
    Image: string;
    Name: string;
    Size: string;
    Amount: number;
    Quantity: number;
    SalePrice: number;
    OriginalPrice: number;

    constructor(){
        this.CartID = '';
        this.UserID = '';
        this.ProductID = '';
        this.Image = '';
        this.Name = '';
        this.Size = '';
        this.Amount = 0;
        this.Quantity = 0;
        this.SalePrice = 0;
        this.OriginalPrice = 0;
    }
}

export class BillModel{
    BillID: string;
    CartID: string;
    OrderDate: Date;
    DeliveryDate: Date;
    ReceiverName: string;
    ReceiverPhone: string;
    DeliveryAddress: string;
    ProvinceName: string;
    DistrictName: string;
    DiscountCode: string;
    DeliveryFee: number;
    TotalPrice: number;
    Status: string;

    constructor(){
        this.BillID = '';
        this.CartID = '';
        this.OrderDate = null;
        this.DeliveryDate = null;
        this.ReceiverName = '';
        this.ReceiverPhone = '';
        this.DeliveryAddress = '';
        this.ProvinceName = '';
        this.DistrictName = '';
        this.DiscountCode = '';
        this.DeliveryFee = 0;
        this.TotalPrice = 0;
        this.Status = '';
    }
}

export class MessageModel{
    Title: string;
    Content: string;
    BackToHome: boolean;

    constructor(){
        this.Title = '';
        this.Content = '';
        this.BackToHome = false;
    }
}

export class KeyWord{
    static Value: string='';
}

export class TestModel{
    Name: string;
    Image: File;
}

export class ProvinceModel{
    ProvinceID: string;
    ProvinceName: string;
    DeliveryFee: number;
}

export class DistrictModel{
    DistrictID: string;
    ProvinceID: string;
    DistrictName: string;
}

export class RatingModel{
    UserID: string;
    UserName: string;
    ProductID: string;
    Title: string;
    Comment: string;
    Star: number;
    RatingDate: Date;
}