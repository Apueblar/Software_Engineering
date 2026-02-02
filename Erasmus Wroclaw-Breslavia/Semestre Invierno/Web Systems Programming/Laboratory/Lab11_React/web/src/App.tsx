import { useState } from 'react';
import MenuBar from './components/MenuBar';
import FooterBar from './components/FooterBar';
import MainPanel from './components/MainPanel';
import { ArticleService } from './services/ArticleService';
import type { Article } from './types/Article';
import './App.css';

function App() {
  const [articles] = useState<Article[]>(ArticleService.getArticles());

  return (
    <div className="app">
      <MenuBar />
      
      <MainPanel 
        articles={articles}
      />
      
      <FooterBar />
    </div>
  );
}

export default App;