/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#fef3e2',
          100: '#fde7c5',
          200: '#fbcf8c',
          300: '#f9b752',
          400: '#f79f19',
          500: '#f58800',
          600: '#c46d00',
          700: '#935200',
          800: '#623700',
          900: '#311c00',
        }
      }
    },
  },
  plugins: [],
}
