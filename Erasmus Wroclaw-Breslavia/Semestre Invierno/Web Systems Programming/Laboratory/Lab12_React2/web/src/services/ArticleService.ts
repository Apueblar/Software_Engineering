import type { Article } from "../types/Article";
import type { Category } from "../types/Category";

const API_URL = "http://localhost:3000/api";

class ArticleServiceClass {
  async getArticles(): Promise<Article[]> {
    const response = await fetch(`${API_URL}/articles`);
    if (!response.ok) throw new Error("Failed to fetch articles");
    return response.json();
  }

  async getArticleById(id: number): Promise<Article | null> {
    const response = await fetch(`${API_URL}/articles/${id}`);
    if (!response.ok) return null;
    return response.json();
  }

  async addArticle(article: Omit<Article, "id">): Promise<Article> {
    const response = await fetch(`${API_URL}/articles`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(article),
    });
    if (!response.ok) throw new Error("Failed to add article");
    return response.json();
  }

  async updateArticle(id: number, article: Omit<Article, "id">): Promise<Article> {
    const response = await fetch(`${API_URL}/articles/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(article),
    });
    if (!response.ok) throw new Error("Failed to update article");
    return response.json();
  }

  async deleteArticle(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/articles/${id}`, {
      method: "DELETE",
    });
    if (!response.ok) throw new Error("Failed to delete article");
  }

  async getCategories(): Promise<Category[]> {
    const response = await fetch(`${API_URL}/categories`);
    if (!response.ok) throw new Error("Failed to fetch categories");
    return response.json();
  }

  async getCategoryById(id: number): Promise<Category | null> {
    const response = await fetch(`${API_URL}/categories/${id}`);
    if (!response.ok) return null;
    return response.json();
  }

  async addCategory(category: Omit<Category, "id">): Promise<Category> {
    const response = await fetch(`${API_URL}/categories`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(category),
    });
    if (!response.ok) throw new Error("Failed to add category");
    return response.json();
  }

  async updateCategory(id: number, category: Omit<Category, "id">): Promise<Category> {
    const response = await fetch(`${API_URL}/categories/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(category),
    });
    if (!response.ok) throw new Error("Failed to update category");
    return response.json();
  }

  async deleteCategory(id: number): Promise<void> {
    const response = await fetch(`${API_URL}/categories/${id}`, {
      method: "DELETE",
    });
    if (!response.ok) throw new Error("Failed to delete category");
  }
}

export const ArticleService = new ArticleServiceClass();