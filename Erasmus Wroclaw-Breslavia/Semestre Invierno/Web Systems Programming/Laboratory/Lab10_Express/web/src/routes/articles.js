const express = require('express');
const { Article } = require('../models');
const { body, validationResult } = require('express-validator');
const router = express.Router();

router.get('/', async (req,res,next)=>{
  try{
    const articles = await Article.findAll({ order:[['id','ASC']] });
    res.render('articles/list',{articles});
  }catch(err){ next(err); }
});

router.get('/new',(req,res)=> res.render('articles/form',{article:{},action:'/articles',method:'POST'}));

router.post('/',
  body('name').notEmpty().withMessage('Name required'),
  body('category').notEmpty().withMessage('Category required'),
  body('price').isFloat({min:0}).withMessage('Price must be >=0'),
  async (req,res,next)=>{
    const errors = validationResult(req);
    if(!errors.isEmpty()) return res.status(400).render('articles/form',{article:req.body, errors:errors.array(), action:'/articles', method:'POST'});
    try{
      await Article.create(req.body);
      res.redirect('/articles');
    }catch(err){ next(err); }
});

router.get('/:id', async (req,res,next)=>{
  try{
    const article = await Article.findByPk(req.params.id);
    if(!article) return res.status(404).render('error',{message:'Article not found'});
    res.render('articles/view',{article});
  }catch(err){ next(err); }
});

router.get('/:id/edit', async (req,res,next)=>{
  try{
    const article = await Article.findByPk(req.params.id);
    if(!article) return res.status(404).render('error',{message:'Article not found'});
    res.render('articles/form',{article, action:`/articles/${article.id}?_method=PUT`, method:'POST'});
  }catch(err){ next(err); }
});

router.post('/:id', async (req,res,next)=>{
  // handle update via POST (no method-override) — id immutable
  try{
    const article = await Article.findByPk(req.params.id);
    if(!article) return res.status(404).render('error',{message:'Article not found'});
    await article.update({ name:req.body.name, category:req.body.category, price:req.body.price, description:req.body.description });
    res.redirect('/articles');
  }catch(err){ next(err); }
});

router.post('/:id/delete', async (req,res,next)=>{
  try{
    const article = await Article.findByPk(req.params.id);
    if(article) await article.destroy();
    res.redirect('/articles');
  }catch(err){ next(err); }
});

module.exports = router;
