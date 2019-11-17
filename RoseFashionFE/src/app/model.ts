export class UserModel{
    Username: string;
    Password: string;
    FullName: string;
    Gender: string;
    DOB: Date;
    Email: string;
    Address: string;
    Phone: string;
    Role: string;
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
    Price: number;
}