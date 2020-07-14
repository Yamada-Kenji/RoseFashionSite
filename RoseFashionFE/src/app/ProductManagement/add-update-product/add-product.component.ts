import { Component, OnInit } from '@angular/core';
import { CategoryModel, ProductModel, MessageModel } from 'src/app/Shared/model';
import { Location } from '@angular/common';
import { ProductService } from 'src/app/Shared/product-service';
import { CategoryService } from 'src/app/Shared/category-service';
import { MessageService } from 'src/app/Shared/message-service';
import { ActivatedRoute, Router } from '@angular/router';
import { FormGroup, FormBuilder } from '@angular/forms';

@Component({
  selector: 'app-add-product',
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {

  title: string = '';
  uploadForm: FormGroup;
  emptyfile: boolean = true;
  filechanged: boolean = false;
  tempimage: string = '';
  currentimage: string = '';
  message: any;
  product: ProductModel = new ProductModel();
  //{ ProductID: '', Name: '', Color: '#000000', Size: [] = ['S', 'M', 'L', 'XL', 'XXL'], CategoryID: '', Description: '', Quantity: [] = [0, 0, 0, 0, 0], Image: '', Price: 0, SoldOut: false };
  categorylist: CategoryModel[] = [];
  maxquantity: number = 999;
  minquantity: number = 0;
  minprice: number = 0;
  maincategory: string = '';
  categoryrequire: boolean;
  namerequire: boolean;
  imagerequire: boolean;
  addfunction: boolean = true;
  loading: boolean = false;
  sizes = [
    { name: 'S', quantity: 0, checked: false },
    { name: 'M', quantity: 0, checked: false },
    { name: 'L', quantity: 0, checked: false },
    { name: 'XL', quantity: 0, checked: false },
    { name: 'XXL', quantity: 0, checked: false }
  ]

  constructor(private productService: ProductService,
    private categoryService: CategoryService,
    private messageService: MessageService,
    private route: ActivatedRoute,
    private router: Router,
    private location: Location,
    private formBuilder: FormBuilder) {
    this.uploadForm = this.formBuilder.group({
      selectedfile: ''
    });
  }

  ngOnInit() {
    window.scrollTo(0, 0);
    this.categoryService.GetAllCategory()
      .toPromise().then(result => {
        this.categorylist = result;
        var productid = this.route.snapshot.paramMap.get('productid');
        if (productid) {
          this.productService.GetProductDetail(productid).toPromise().then(p => {
            this.product = p;
            this.currentimage = this.tempimage = p.Image;
            this.SetCategory();
          });
          this.addfunction = false;
          this.title = 'Chỉnh sửa sản phẩm';
        }
        else {
          //this.SetMainCategory();
          this.title = 'Thêm sản phẩm';
        }
      });
  }

  // đọc dữ liệu file ảnh sang dạng url
  //nguồn tham khảo https://stackblitz.com/edit/angular-file-upload-preview?file=app%2Fapp.component.html
  onSelectFile(event) {
    if (event.target.files && event.target.files[0]) {
      //this.emptyfile = false;
      this.filechanged = true;
      const file = event.target.files[0];
      this.uploadForm.get('selectedfile').setValue(file);

      var reader = new FileReader();

      reader.readAsDataURL(event.target.files[0]); // read file as data url

      reader.onload = (event) => { // called once readAsDataURL is completed
        this.currentimage = this.tempimage = reader.result.toString();
        this.product.Image='changed';
      }
    }
    else {
      this.currentimage = this.tempimage;
      // if (this.currentimage == '') {
      //   this.tempimage = '';
      //   this.emptyfile = true;
      // }
      // else {
      //   this.tempimage = this.product.Image;
      //   this.emptyfile = false;
      //   this.filechanged = false;
      // }
    }
  }

  showfile() {
    return this.uploadForm.get('selectedfile').value;
  }

  onSubmit() {
    console.log(this.product);
    if (this.CheckEmptyValue() == false) return;
    if (this.product.Price == 0) {
      if (!confirm('Bạn đang lưu thông tin sản phẩm với giá là 0 VNĐ.\nBạn vẫn muốn tiếp tục?')) {
        return;
      }
    }
    if (!confirm('Xác nhận lưu thay đổi?')) {
      return;
    }
    if (this.addfunction == true) this.AddProduct();
    else this.UpdateProduct();
    window.scrollTo(0, 0);
  }

  Cancel() {
    if (confirm('Bạn có muốn hủy toàn bộ thay đổi đã thực hiện tại trang này không?')) {
      this.router.navigate(['/view-product-list']);
    }
  }

  SetMainCategory() {
    var i = 0;
    while (i < this.categorylist.length) {
      if (this.categorylist[i].MainCategory == null) {
        this.maincategory = this.categorylist[i].CategoryID;
        break;
      }
      i++;
    }
  }

  OnQuantityChange(index: number) {
    if (this.product.Quantity[index] % 1 !== 0 || this.product.Quantity[index] == null) this.product.Quantity[index] = this.minquantity;
    if (this.product.Quantity[index] > this.maxquantity) this.product.Quantity[index] = this.maxquantity;
    if (this.product.Quantity[index] <= this.minquantity) this.product.Quantity[index] = this.minquantity;

  }

  OnPriceChange() {
    if (this.product.Price % 1 !== 0 || this.product.Price == null) this.product.Price = this.minprice;
    if (this.product.Price < this.minprice) this.product.Price = this.minprice;
  }

  OnDiscountChange() {
    if (this.product.DiscountPercent % 1 !== 0 || this.product.DiscountPercent == null) this.product.DiscountPercent = 0;
    if (this.product.DiscountPercent > 100) this.product.DiscountPercent = 100;
    if (this.product.DiscountPercent < 0) this.product.DiscountPercent = 0;
  }

  CheckEmptyValue() {
    //kiem tra name
    if (this.product.Name == '') this.namerequire = true;
    else this.namerequire = false;
    //kiem tra category
    if (this.product.CategoryID == '') this.categoryrequire = true;
    else this.categoryrequire = false;
    //kiem tra anh
    if (this.currentimage == '') this.imagerequire = true;
    else this.imagerequire = false;
    if (!this.namerequire && !this.categoryrequire && !this.imagerequire) return true;
    return false;
  }

  async AddProduct() {
    this.loading = true;
    await this.productService.AddProduct(this.product)
      .toPromise().then(r => {
        const formData = new FormData();
        formData.append('filetoupload', this.uploadForm.get('selectedfile').value);
        formData.append('imagename', r);

        console.log(formData.get('imagename'));
        this.productService.UploadImage(formData).subscribe(
          res => {
            this.loading = false;
            alert('Thêm sản phẩm thành công');
            //this.location.back();
            this.product = new ProductModel();
            this.tempimage = '';
            this.currentimage = '';
            this.maincategory = '';
          },
          err => alert('Đã có lỗi xảy ra. (error 02)')
        );

      })
      .catch(() => alert('Đã có lỗi xảy ra. (error 01)'));
  }

  async GetAllCategory() {
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  GetSelectedSizeAndQuantity() {
    this.product.Size = this.sizes.filter(opt => opt.checked).map(opt => opt.name);
    this.product.Quantity = this.sizes.filter(opt => opt.checked).map(opt => opt.quantity);
  }

  SetCategory() {
    var i: number = 0;
    for (i; i < this.categorylist.length; i++) {
      if (this.categorylist[i].CategoryID == this.product.CategoryID) {
        this.maincategory = this.categorylist[i].MainCategory; break;
      }
    }
  }

  UpdateProduct() {
    this.loading = true;
    this.productService.UpdateProduct(this.product)
      .toPromise().then(r => {
        if (this.filechanged) {
          const formData = new FormData();
          formData.append('filetoupload', this.uploadForm.get('selectedfile').value);
          formData.append('imagename', r);

          console.log(formData.get('imagename'));
          this.productService.UploadImage(formData).subscribe(
            res => {
              this.loading = false;
              alert('Cập nhật sản phẩm thành công');
              this.location.back();
            },
            err => {
              this.loading = false;
              alert('Đã có lỗi xảy ra. (error 02)');
            }
          );
        }
        else {
          this.loading = false;
          alert('Cập nhật sản phẩm thành công');
          this.location.back();
        }
      })
      .catch(() => {
        this.loading = false;
        alert('Đã có lỗi xảy ra.(error 01)');
      });
  }

  Save() {
    console.log(this.product);
    if (this.CheckEmptyValue() == false) return;
    if (this.product.Price == 0) {
      if (!confirm('Bạn đang lưu thông tin sản phẩm với giá là 0 VNĐ.\nBạn vẫn muốn tiếp tục?')) {
        return;
      }
    }
    if (this.addfunction == true) this.AddProduct();
    else this.UpdateProduct();
  }

}
