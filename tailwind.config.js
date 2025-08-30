/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
      "./templates/**/*.templ",
      "./templates/**/*.html",
      "./internal/static/**/*.html",
      "./cmd/**/*.go",
      "./internal/**/*.go",
    ],
    theme: {
      extend: {},
    },
    plugins: [],
  }