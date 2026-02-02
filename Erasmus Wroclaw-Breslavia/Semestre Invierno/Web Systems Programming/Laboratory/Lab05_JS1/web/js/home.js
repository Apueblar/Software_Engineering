"use strict";

console.log("Hello world!");

/* home.js — external JavaScript for "JavaScript basics — Part 1" page
   Contains:
   - solveEq(a,b[,c]) : solves linear (2 args) or quadratic (3 args)
     equations and logs results
   - count(...)        : counts length/digits/elements based on first argument
   - Movie constructor + movieArr sample
   - table generation using document.writeln() and for...of

   Note: This file is intended to be included at the end of the HTML body so
   document.write / writeln runs while the page is loading.
*/

// ---- 1) solveEq -----------------------------------------------------------
function solveEq(a, b, c) {
  // Support calling with 2 args (linear: a*x + b = 0)
  // or 3 args (quadratic: a*x^2 + b*x + c = 0)
  if (typeof c === "undefined") { // Linear case
    // linear equation: a*x + b = 0
    if (a === 0) {
      if (b === 0) {
        console.log("Linear: 0x + 0 = 0 → infinite solutions");
        return { type: "infinite" };
      }
      console.log("Linear: 0x + " + b + " = 0 → no solution");
      return { type: "none" };
    }
    const rootLinear = -b / a;
    console.log("Linear: " + a + "x + " + b + " = 0 → x = " + rootLinear);
    return { root: rootLinear, type: "linear" };
  }

  // Quadratic case
  if (a === 0) {
    // degrade to linear: b*x + c = 0
    console.log("Quadratic called with a = 0 → degenerates to linear.");
    return solveEq(b, c);
  }

  const D = b * b - 4 * a * c;
  if (D < 0) {
    console.log("Quadratic: Discriminant D = " + D + " < 0 → no real roots");
    return { discriminant: D, type: "complex" };
  }

  if (D === 0) {
    const singleRoot = -b / (2 * a);
    console.log("Quadratic: D = 0 → one real root");
    console.log("x = " + singleRoot);
    return { roots: [singleRoot], type: "double" };
  }

  const sqrtD = Math.sqrt(D);
  const x1 = (-b + sqrtD) / (2 * a);
  const x2 = (-b - sqrtD) / (2 * a);
  console.log("Quadratic: D = " + D + " → real roots");
  console.log("x1 = " + x1 + ", x2 = " + x2);
  return { discriminant: D, roots: [x1, x2], type: "two" };
}

document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("eqForm");
  const resultDiv = document.getElementById("equation-result");

  if (!form || !resultDiv) {
    return;
  }

  form.addEventListener("submit", function (e) {
    e.preventDefault(); // stop page reload

    const a = parseFloat(document.getElementById("a").value);
    const b = parseFloat(document.getElementById("b").value);
    const cInput = document.getElementById("c").value.trim();

    let result;
    if (cInput === "") {
      result = solveEq(a, b); // linear
    } else {
      const c = parseFloat(cInput);
      result = solveEq(a, b, c); // quadratic
    }

    // Show result on the page
    resultDiv.innerHTML = `<strong>Result:</strong> ${JSON.stringify(result)}`;
  });
});

// ---- 2) count -------------------------------------------------------------
function count(val) {
  if (typeof val === "undefined") {
    console.log("count(): 0");
    return 0;
  }

  // String
  if (typeof val === "string") {
    console.log("count(string):", val, " -> ", val.length);
    return val.length;
  }

  // Number
  if (typeof val === "number") {
    const digitsOnly = String(val).replace(/[^0-9]/g, "");
    console.log("count(number):", digitsOnly.length, "(digits in", val, ")");
    return digitsOnly.length;
  }

  // Array
  if (Array.isArray(val)) {
    console.log("count(array):", val.length);
    return val.length;
  }

  // Fallback: if object has length property numeric
  if (val && typeof val.length === "number") {
    console.log("count(fallback .length):", val.length);
    return val.length;
  }

  console.log("count: unsupported type → 0");
  return 0;
}

document.addEventListener("DOMContentLoaded", function () {
  const input = document.getElementById("countInput");
  const resultDiv = document.getElementById("countResult");

  if (!input) {
    return;
  }

  input.addEventListener("input", function () {
    const value = input.value.trim();
    let parsedValue;

    try {
      // Try to interpret arrays or numbers using JSON
      if (value.startsWith("[") && value.endsWith("]")) {
        parsedValue = JSON.parse(value); // array
      } else if (value !== "" && !Number.isNaN(Number(value))) {
        parsedValue = Number(value); // number
      } else {
        parsedValue = value; // string
      }
    } catch (e) {
      parsedValue = value; // fallback if JSON parse fails
    }

    const len = count(parsedValue);
    resultDiv.innerHTML = `<strong>Length:</strong> ${len}`;
  });
});

// ---- 3) Movies + table generation -----------------------------------------
class Movie {
  constructor(title, director, durationMin, releaseDate, genre, language) {
    this.title = title;
    this.director = director;
    this.duration = durationMin + " min";
    this.releaseDate = releaseDate;
    this.genre = genre;
    this.language = language;
  }
}

const movieArr = [
  new Movie(
    "The Example",
    "A. Director",
    120,
    "2020-05-20",
    "Drama",
    "English"
  ),
  new Movie(
    "Another Film",
    "B. Filmmaker",
    95,
    "2018-11-02",
    "Comedy",
    "French"
  ),
  new Movie(
    "Sci-Fi Epic",
    "C. Vision",
    142,
    "2023-07-15",
    "Sci-Fi",
    "English"
  )
];

function writeMoviesTable(arr) {
  if (!arr || arr.length === 0) {
    document.writeln("<p>No movies available.</p>");
    return;
  }

  document.writeln("<table>");
  document.writeln("<caption>Movie list</caption>");
  document.writeln("<thead><tr>");

  // Use the keys of the first object for headers
  for (const key of Object.keys(arr[0])) {
    document.writeln("<th>" + key + "</th>");
  }

  document.writeln("</tr></thead>");
  document.writeln("<tbody>");

  // Use for...of to iterate rows
  for (const movie of arr) {
    document.writeln("<tr>");
    for (const key of Object.keys(movie)) {
      document.writeln("<td>" + movie[key] + "</td>");
    }
    document.writeln("</tr>");
  }

  document.writeln("</tbody></table>");
}

// Generate the table while the page is loading
writeMoviesTable(movieArr);
