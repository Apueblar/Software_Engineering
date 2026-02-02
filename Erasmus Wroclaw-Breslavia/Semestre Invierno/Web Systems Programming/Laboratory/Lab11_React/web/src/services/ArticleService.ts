import type { Article } from '../types/Article';

export class ArticleService {
  static getArticles(): Article[] {
    return [
      { 
        id: 1, 
        name: 'Laptop', 
        category: 'Electronics', 
        price: 1299.99, 
        description: 'High-performance laptop with 16GB RAM and 512GB SSD' 
      },
      { 
        id: 2, 
        name: 'Wireless Mouse', 
        category: 'Electronics', 
        price: 29.99, 
        description: 'Ergonomic wireless mouse with precision tracking' 
      },
      { 
        id: 3, 
        name: 'Coffee Maker', 
        category: 'Appliances', 
        price: 89.99, 
        description: 'Programmable coffee maker with thermal carafe' 
      },
      { 
        id: 4, 
        name: 'Office Chair', 
        category: 'Furniture', 
        price: 249.99, 
        description: 'Ergonomic office chair with lumbar support' 
      },
      { 
        id: 5, 
        name: 'Headphones', 
        category: 'Electronics', 
        price: 199.99, 
        description: 'Noise-cancelling over-ear headphones' 
      },
      { 
        id: 6, 
        name: 'Desk Lamp', 
        category: 'Furniture', 
        price: 45.99, 
        description: 'LED desk lamp with adjustable brightness' 
      },
      { 
        id: 7, 
        name: 'Water Bottle', 
        category: 'Accessories', 
        price: 24.99, 
        description: 'Insulated stainless steel water bottle, 32oz' 
      },
      { 
        id: 8, 
        name: 'Keyboard', 
        category: 'Electronics', 
        price: 79.99, 
        description: 'Mechanical keyboard with RGB backlight' 
      },
    ];
  }
}