/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Poppins', 'sans-serif'],
      },
      colors: {
        lavender: {
          50: '#FAF8FF',
          100: '#F4EFFF',
          200: '#E9DEFF',
          300: '#D9C5FF',
          400: '#C4A3FF',
          500: '#AD7EFF',
          600: '#9655FF',
          700: '#7C3AED',
        },
        mint: {
          50: '#F0FDF9',
          100: '#CCFBEF',
          200: '#99F6E0',
          300: '#5FE9D0',
          400: '#2DD4BF',
          500: '#14B8A6',
          600: '#0D9488',
          700: '#0F766E',
        },
        peach: {
          50: '#FFF8F3',
          100: '#FFEDD5',
          200: '#FED7AA',
          300: '#FDBA74',
          400: '#FB923C',
          500: '#F97316',
          600: '#EA580C',
          700: '#C2410C',
        },
        sky: {
          50: '#F0F9FF',
          100: '#E0F2FE',
          200: '#BAE6FD',
          300: '#7DD3FC',
          400: '#38BDF8',
          500: '#0EA5E9',
          600: '#0284C7',
          700: '#0369A1',
          800: '#becaf2',
        },
      },
      borderRadius: {
        'clay': '18px',
        'clay-lg': '22px',
        'clay-xl': '28px',
      },
      boxShadow: {
        'clay': '0 8px 20px -6px rgba(0, 0, 0, 0.08), 0 4px 8px -4px rgba(0, 0, 0, 0.05)',
        'clay-hover': '0 12px 28px -8px rgba(0, 0, 0, 0.12), 0 6px 12px -4px rgba(0, 0, 0, 0.08)',
        'clay-pressed': '0 2px 8px -2px rgba(0, 0, 0, 0.08), inset 0 2px 4px rgba(0, 0, 0, 0.06)',
        'clay-inset': 'inset 0 2px 8px rgba(0, 0, 0, 0.06)',
      },
    },
  },
  plugins: [],
};
