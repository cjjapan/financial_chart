// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://cjjapan.github.io',
	base: 'financial_chart',
	devToolbar: { enabled: false },
	integrations: [
		starlight({
			title: 'financial_chart',
			customCss: [
				'./src/styles/custom.css',
			],
			plugins: [
			],
			social: [{
				icon: 'github', label: 'GitHub', href: 'https://github.com/cjjapan/financial_chart'
			}, {
				icon: 'seti:dart', label: 'Pub.dev', href: 'https://pub.dev/packages/financial_chart'
			}
			],
			head: [
				// Adding google analytics
				{
					tag: 'script',
					content: `
						var hostname = window.location.hostname;
						if (hostname === "localhost" || hostname === "127.0.0.1") {
							console.log("Google Analytics is disabled on localhost.");
							window['ga-disable-G-KV9ZVYXLWH'] = true;
						}
					`,
				},
				{
					tag: 'script',
					attrs: {
						src: `https://www.googletagmanager.com/gtag/js?id=G-KV9ZVYXLWH`,
					},
				},
				{
					tag: 'script',
					content: `
						window.dataLayer = window.dataLayer || [];
						function gtag(){dataLayer.push(arguments);}
						gtag('js', new Date());
						gtag('config', 'G-KV9ZVYXLWH');
					`,
				},
			],
			sidebar: [
				{
					label: 'Guides',
					autogenerate: { directory: 'guides' },
				},
				{
					label: 'Graphs',
					autogenerate: { directory: 'graphs' },
				},
				{
					label: 'Markers',
					autogenerate: { directory: 'markers' },
				},
				{
					label: 'Components',
					autogenerate: { directory: 'components' },
				},
			],
		}),
	],
});
