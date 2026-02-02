const { Sequelize, DataTypes } = require('sequelize');
const sequelize = new Sequelize({ dialect:'sqlite', storage:'database.sqlite' });

const Article = sequelize.define('Article',{
  name: { type: DataTypes.STRING, allowNull:false },
  category: { type: DataTypes.STRING, allowNull:false },
  price: { type: DataTypes.FLOAT, allowNull:false, defaultValue:0 },
  description: { type: DataTypes.TEXT }
},{ timestamps:true });

module.exports = { sequelize, Article };
