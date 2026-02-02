// src/app.js

const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const engine = require('ejs-mate');
const { sequelize } = require('./models');
const articleRouter = require('./routes/articles');

const app = express();

/**
 * View engine and static assets
 * - Use ejs-mate so templates can call layout(...)
 * - Views are in src/views
 * - Public assets are expected at project-root/public
 */
app.engine('ejs', engine);
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, '..', 'public')));

/**
 * Body parsing
 */
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

/**
 * Global/default locals and helpers for templates
 * - app.locals provides global defaults
 * - res.locals is set per-request (menu, request, flash)
 */
app.locals.title = 'Articles App';

app.use((req, res, next) => {
  // Menu used by the layout partial
  res.locals.menu = [
    { path: '/articles', label: 'Article list' },
    { path: '/articles/new', label: 'Add new article' },
    { path: '/about', label: 'About' }
  ];

  // Expose request so templates can highlight active menu item
  res.locals.request = req;

  // Simple flash placeholder (not persistent across redirects).
  // If you later add express-session + connect-flash, replace this.
  res.locals.flash = res.locals.flash || null;

  next();
});

/**
 * Routes
 */
app.get('/', (req, res) => res.redirect('/articles'));
app.use('/articles', articleRouter);

app.get('/about', (req, res) => {
  res.render('about', {
    developer: { 
      name: 'Álvaro Puebla', 
      email: '293867@student.pwr.edu.pl', 
      studentId: '293867'
    }
  });
});

/**
 * 404 handler (must be after routes)
 */
app.use((req, res) => {
  res.status(404).render('error', { message: 'Page not found' });
});

/**
 * Global error handler
 * - Logs error server-side and renders a friendly error page
 */
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  // Avoid leaking stack traces to users in production; show message only
  res.status(500).render('error', { message: err && err.message ? err.message : 'Server error' });
});

/**
 * Start server after DB sync
 */
const PORT = process.env.PORT || 3000;

(async function start() {
  try {
    await sequelize.sync(); // create tables if needed
    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start application:', err);
    process.exit(1);
  }
})();

module.exports = app;
