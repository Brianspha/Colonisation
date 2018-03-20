//Code for login/Registration



//End code for login registration

//Start Main UI code

// use local storage
// click of add to basket takes all info of that product
// adds and stores in basket
// refresh still stores items in basket
// items can be removed from basket
const product = document.querySelectorAll(".shopping__product");
const menu = document.querySelector(".menu__container");
const basket = document.querySelector(".basket");
const shoppingArea = document.querySelector(".shopping");

// point of local storage
let basketItems = JSON.parse(localStorage.getItem("basketItems", basketItems)) || [];

// product data
const products = [
  {
    title: "Product",
    imgSrc:
      "https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE0NTg5fQ&s=73bb845a19c8ffd1e52def83c307ae57",
    price: "£1001"
  },
  {
    title: "Product",
    imgSrc:
      "https://images.unsplash.com/photo-1475173641776-50e70b746de8?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE0NTg5fQ&s=924001d3b574be8a5fe2b762762e6c3e",
    price: "£1002"
  },
  {
    title: "Product",
    imgSrc:
      "https://images.unsplash.com/photo-1506638389872-eaf0cffb94bc?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE0NTg5fQ&s=77b49b4280f51b1c02e521b9462e9660",
    price: "£1003"
  },
  {
    title: "Product",
    imgSrc:
      "https://images.unsplash.com/photo-1491553895911-0055eca6402d?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE0NTg5fQ&s=7a0275305e292485c8b784b4f408f7c4",
    price: "£1001"
  },
  {
    title: "Product",
    imgSrc:
      "https://images.unsplash.com/photo-1468495244123-6c6c332eeece?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE0NTg5fQ&s=3832e90087eca10453523207789e5d69",
    price: "£1002"
  },
  {
    title: "Product",
    imgSrc:
      "https://images.unsplash.com/photo-1472950755543-5293dbab893a?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE0NTg5fQ&s=7ab9a10ddd5191a23c0d884f67f06eaf",
    price: "£1003"
  }
];

// create the html from data
shoppingArea.innerHTML = products
  .map((product, i) => {
    return `
       <div class='shopping__product'>
    <h3 class='shopping__product__title'>${product.title + ' ' + (i+1)}</h3>
    <img class = 'shopping__product__img' src="${product.imgSrc}">
    <p class='shopping__product__price'>${product.price}</p>
    <button class='shopping__product__button'>Add to basket</button>
  </div>
      `;
  }).join("");

// on click of button make copy of info
const button = document.querySelectorAll(".shopping__product__button");
button.forEach(item => item.addEventListener("click", getItem));

function getItem(e) {
  e.preventDefault();
  // targets for html copies
  let productTitle = $(e.target)
    .closest(".shopping__product")
    .find(".shopping__product__title")
    .html();

  let productImg = $(e.target)
    .closest(".shopping__product")
    .find(".shopping__product__img")
    .attr("src");

  let productPrice = $(e.target)
    .closest(".shopping__product")
    .find(".shopping__product__price")
    .html();
  //store in object
  let items = {
    productTitle,
    productImg,
    productPrice
  };
  // add to array
  basketItems.push(items);
  // update storage
  localStorage.setItem("basketItems", JSON.stringify(basketItems));
 // update dom with local storage basket items
  createItem(basketItems, menu);
  // refresh to display
  location = location.href;
}

// create copy of item in basket function
function createItem(products = [], position) {
  position.innerHTML = products
    .map((item, i) => {
      return `
            <div class ="basket__items" data-basket-count = "${i}"> 
              <h3 class ="basket__items__title">${item.productTitle}</h3>
              <img class ="basket__items__img" src = "${item.productImg}">
              <p class ="basket__items__price">${item.productPrice}</p>
          <svg width="24" height="24" viewBox="0 0 24 24" class ='bomb'>
            <path d="M11.25,6A3.25,3.25 0 0,1 14.5,2.75A3.25,3.25 0 0,1 17.75,6C17.75,6.42 18.08,6.75 18.5,6.75C18.92,6.75 19.25,6.42 19.25,6V5.25H20.75V6A2.25,2.25 0 0,1 18.5,8.25A2.25,2.25 0 0,1 16.25,6A1.75,1.75 0 0,0 14.5,4.25A1.75,1.75 0 0,0 12.75,6H14V7.29C16.89,8.15 19,10.83 19,14A7,7 0 0,1 12,21A7,7 0 0,1 5,14C5,10.83 7.11,8.15 10,7.29V6H11.25M22,6H24V7H22V6M19,4V2H20V4H19M20.91,4.38L22.33,2.96L23.04,3.67L21.62,5.09L20.91,4.38Z"></path>
          </svg>
   <hr>
          </div> `;
    })
    .join("");
}
createItem(basketItems, menu);

const basketBomb = document.querySelectorAll(".bomb");
// on click of bomb delete basket item
basketBomb.forEach(bItem =>
  bItem.addEventListener("click", function() {
    createItem(basketItems, menu);
    // get the product number
    let clickedIndex = $(this)
      .closest(".basket__items")
      .attr("data-basket-count");
      // remove based on product index - click remove that item
    basketItems.splice(clickedIndex, 1);
    //  update the storage
    localStorage.setItem("basketItems", JSON.stringify(basketItems));
    // refresh the page to display
    location = location.href;
  })
);
// drop basket down
basket.addEventListener("click", function() {
  menu.classList.toggle("active-menu");
});


//End MainUI code