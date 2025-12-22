# Print-friendly portfolio CV

[🇫🇷 Version française ci-dessous | French version below]

---

## English
### Main goal
This project is an online portfolio/resume website, designed to present in a clear, elegant, and maintainable way:
  - academic and professional background,
  - experiences (work, volunteer work, projects),
  - technical skills,
  - languages,
  - and personal projects.

The main objective of the project is twofold:
  1.  Present a profile in a readable and professional manner, both on screen and in print.
  2.  Build a clean, modular, and scalable technical base that is easy to maintain over time.

The site is based on a component-oriented architecture (Astro), with particular attention paid to:
  - code readability,
  - design consistency,
  - simplicity of styles,
  - and overall maintainability.

### Installation

1. Clone the repository and install dependencies with pnpm:
```bash
git clone https://github.com/EniumRaphael/portfolio
cd portfolio
pnpm install
```

2. To run it:
```bash
pnpm dev    # Watch mode to see change
```

3. Change the content

Edit the [cv.json template](https://jsonresume.org/schema/) to create your own.
- There is many theme:
    - default
    - blue
    - cyber
    - green
    - red
    - Catppuccin Mocha (mocha)
    - TokyoNight (tokyonight)

4. To deploy it:
```bash
pnpm build  # The build will be in ./dist
```

Based on [Smilesharks/dev-portfolio](https://github.com/Smilesharks/dev-portfolio), with customizations for my own portfolio.
