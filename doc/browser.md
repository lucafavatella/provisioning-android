# Browsers

This document lists privacy-focused Web browsers for Android.

## Brave

Chromium/Blink based.

In [own](https://brave.com/blog/f-droid/) F-Droid repository.

## Cromite

Chromium/Blink based.

Releases in [GitHub](https://github.com/uazo/cromite/releases),
not in [broken own](https://github.com/uazo/cromite/issues/2021) F-Droid repo.

## IronFox

Firefox/Gecko based.

In [own](https://ironfoxoss.org/download/#f-droid) F-Droid repo.

It has [basic per-site process isolation](https://ironfoxoss.org/docs/features/)
(_"Enables [Fission](https://wiki.mozilla.org/Project_Fission) (basic per-site process isolation) by default"_).

On [security](https://ironfoxoss.org/docs/limitations/#security):
> While we do as much as possible to improve the situation,
> it should be noted that Firefox-based web browsers, including IronFox,
> have security deficiencies when compared to Chromium.
> This is especially notable on Android.
> For more details,
> see [this article from GrapheneOS](https://grapheneos.org/usage#web-browsing),
> and [this article from madaidan (a security researcher)](https://madaidans-insecurities.github.io/firefox-chromium.html).
>
> Depending on your threat model,
> it may be preferable to use a Chromium-based browser,
> such as [Vanadium](https://grapheneos.org/features#vanadium) on GrapheneOS,
> or [Cromite](https://github.com/uazo/cromite).

From [the article from GrapheneOS](https://grapheneos.org/usage#web-browsing):
> Chromium-based browsers like Vanadium provide the strongest sandbox implementation,
> leagues ahead of the alternatives.
> It is much harder to escape from the sandbox
> and it provides much more than acting as a barrier
> to compromising the rest of the OS.
> Site isolation enforces security boundaries around each site
> using the sandbox by placing each site into an isolated sandbox.
> It required a huge overhaul of the browser
> since it has to enforce these rules on all the IPC APIs.
> Site isolation is important even without a compromise, due to side channels.
> Browsers without site isolation are very vulnerable to attacks like Spectre.
> On mobile, due to the lack of memory available to apps,
> there are different modes for site isolation.
> Vanadium turns on strict site isolation, matching Chromium on the desktop,
> along with strict origin isolation.
>
> Chromium has decent exploit mitigations, unlike the available alternatives.
> ...
>
> ...
> Chromium is using Network Isolation Keys
> to divide up connection pools, caches and other state based on site
> and this will be the foundation for privacy.
> Chromium itself aims to prevent tracking through mechanisms other than cookies,
> greatly narrowing the scope downstream work needs to cover.
> ...
> The Tor Browser's security is weak which makes the privacy protection weak.
> ...
>
> Avoid Gecko-based browsers like Firefox
> as they're currently much more vulnerable to exploitation
> and inherently add a huge amount of attack surface.
> Gecko doesn't have a WebView implementation (GeckoView is not a WebView implementation),
> so it has to be used alongside the Chromium-based WebView rather than instead of Chromium,
> which means having the remote attack surface of two separate browser engines instead of only one.
> Firefox/Gecko also bypass or cripple a fair bit of the upstream and GrapheneOS hardening work for apps.
> Worst of all, Firefox does not have internal sandboxing on Android.
> This is despite the fact that Chromium semantic sandbox layer on Android
> is implemented via the OS `isolatedProcess` feature,
> which is a very easy to use boolean property for app service processes to provide strong isolation
> with only the ability to communicate with the app running them via the standard service API.
> Even in the desktop version,
> Firefox's sandbox is still substantially weaker (especially on Linux)
> and lacks full support for isolating sites from each other
> rather than only containing content as a whole.
> The sandbox has been gradually improving on the desktop
> but it isn't happening for their Android browser yet.

## WebLibre

Firefox/Gecko based.

https://f-droid.org/en/packages/eu.weblibre.gecko/
["Under active development"](https://github.com/FaFre/WebLibre/blob/0ed1155d356ffb7c51893aeb7419bd67bbbeea82/README.md#L31).

It has [private and isolated tabs](https://github.com/FaFre/WebLibre/blob/0ed1155d356ffb7c51893aeb7419bd67bbbeea82/README.md#L101):
> - Open **Regular**, **Private**, or **Isolated** tabs. Each isolated tab has a separate session from every other tab. Unlike private tabs, isolated tabs remain open after you quit and reopen WebLibre.
