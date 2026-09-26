# Browsers

This document lists privacy-focused Web browsers for Android.

See also https://privacytests.org/android

## Brave

Chromium/Blink based.

[Source](https://github.com/brave/brave-core)
([MPL-2.0](https://github.com/brave/brave-core/blob/064bd2441dd9fd03157da2f4e54a73080d8f5a8c/LICENSE))
and [changelog](https://github.com/brave/brave-browser/blob/master/CHANGELOG_ANDROID.md).

### Releases

In [own](https://brave.com/blog/f-droid/) F-Droid repository.

### Security

It has [partitioning](https://brave.com/privacy-features/):

> * Brave improves upon the limited network-state partitioning that’s already in Chromium.
>   Brave’s [DOM state partitioning](https://brave.com/privacy-updates/7-ephemeral-storage/)
>   will partition each site you visit (knowingly or unknowingly),
>   to prevent cross-site tracking.

Brave used to block by default all third-party storage,
potentially breaking sites.
In 2021, Brave planned to enable "ephemeral site storage",
sharing storage for all first-party instances of the same site (i.e., same eTLD+1),
and clearing storage on last first-party document closure and on browser restart
(browser [comparison](https://brave.com/privacy-updates/14-partitioning-network-state/#:~:text=the%20state%20of%20DOM%20storage%20partitioning%20in%20current%20popular%20browsers)).

> * Brave also expands that partitioning to other storage mechanisms in the browser,
>   [a protection known as network-state partitioning](https://brave.com/privacy-updates/14-partitioning-network-state/).

In 2022, Brave planned to partition
"[network state](https://privacycg.github.io/storage-partitioning/)".

> * Likewise, Brave protects against
>   [some sophisticated forms of pooled-resource attacks](https://brave.com/privacy-updates/13-pool-party-side-channels/).

In 2021, Brave planned to mitigate tracking by side channels
created by limited-but-shared resources managed by - and specific to - the browser
(e.g. WebSockets and limits on in-flight DNS requests)
by making those attacks uncommon and costly
lifting limits on high bandwidth resource pools
and relying on Web users to stop visiting sites starving their user agent.

## Focus/Klar by Firefox

Firefox/Gecko.

Klar [=](https://support.mozilla.org/en-US/kb/difference-between-firefox-focus-and-firefox-klar) German-language version of [Focus](https://play.google.com/store/apps/details?id=org.mozilla.focus).

### Releases

#### F-Droid (disabled)

[Very obsolete](https://gitlab.com/fdroid/fdroiddata/-/blob/e726cf0c14afca57168d450ecee21737f05da2c2/metadata/org.mozilla.klar.yml#L760).
Labelled with anti-feature
[`Tracking`](https://gitlab.com/fdroid/fdroiddata/-/blob/e726cf0c14afca57168d450ecee21737f05da2c2/metadata/org.mozilla.klar.yml#L1-2)
with [MR comment](https://gitlab.com/fdroid/fdroiddata/-/work_items/2289#note_513625558)
in [commit](https://gitlab.com/fdroid/fdroiddata/-/commit/9bd4342504df2aae7848685ce88e9e2593e45faf)
with [maintainer note](https://gitlab.com/fdroid/fdroiddata/-/blob/e726cf0c14afca57168d450ecee21737f05da2c2/metadata/org.mozilla.klar.yml#L755):
> Tracking AntiFeature as Telemetry is opt-out.
> This was due to a bug and fixed with later versions we do not yet have,
> so should those newer versions be added the AntiFeature can be removed again.

#### Guardian Project F-Droid repo (stale, not from source)

In Guardian Project F-Droid repo
([index](https://gitlab.com/guardianproject/fdroid-repo/-/blob/b4bc4d5fad8faed2e7c8de18412cec91563d8b9c/fdroid/repo/index.xml#L29-42)).
Stale
(e.g. on 26th Sep 2026 [Klar 156.0 released on 15th Sep](https://archive.mozilla.org/pub/focus/releases/156.0/android/focus-156.0-android-arm64-v8a/)
not yet [retrieved](https://gitlab.com/guardianproject/wind/fdroid-metadata/-/blob/5c1f5b415fa5637531d0c35b779decb456b8c3b8/download-firefox-klar.py#L58)
with [last apparent repo update on 14th Sep](https://gitlab.com/guardianproject/fdroid-repo/-/commits/b4bc4d5fad8faed2e7c8de18412cec91563d8b9c)).
Labelled with anti-feature
[`NonFreeComp`](https://gitlab.com/guardianproject/wind/fdroid-metadata/-/blob/5c1f5b415fa5637531d0c35b779decb456b8c3b8/metadata/org.mozilla.klar/en-US/antifeatures/NonFreeComp.txt#L1):
> Firefox Klar uses a number of proprietary Google Play Services libraries,
> such as Google In-App Payments, Firebase Cloud Messaging and others.

#### Obtainium

Focus
([repo](https://github.com/ImranR98/apps.obtainium.imranr.dev/blob/2a62ed9288f9efe8e888f27be11d9f88e21df7a1/public/data/apps/complex/org.mozilla.focus.json)
/[website](https://apps.obtainium.imranr.dev/apps?categoryMode=inclusive&sort=popular&q=firefox+focus)),
Klar
([repo](https://github.com/ImranR98/apps.obtainium.imranr.dev/blob/2a62ed9288f9efe8e888f27be11d9f88e21df7a1/public/data/apps/complex/org.mozilla.klar.json)
/[website](https://apps.obtainium.imranr.dev/apps?categoryMode=inclusive&sort=popular&q=firefox+klar)).

### Security

Performing well on https://privacytests.org/android
(similarly to Brave).

## Cromite

Chromium/Blink based.

### Releases

Releases in [GitHub](https://github.com/uazo/cromite/releases),
not in [broken own](https://github.com/uazo/cromite/issues/2021) F-Droid repo.

## IronFox

Firefox/Gecko based.

### Releases

In [own](https://ironfoxoss.org/download/#f-droid) F-Droid repo.

### Security

[Uses](https://ironfoxoss.org/docs/features/) configs
[from](https://codeberg.org/celenity/Phoenix/wiki/features.md)
[Phoenix](https://codeberg.org/celenity/Phoenix/wiki/features-android.md).

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

### Releases

https://f-droid.org/en/packages/eu.weblibre.gecko/
["Under active development"](https://github.com/FaFre/WebLibre/blob/0ed1155d356ffb7c51893aeb7419bd67bbbeea82/README.md#L31).

### Security

It has [private and isolated tabs](https://github.com/FaFre/WebLibre/blob/0ed1155d356ffb7c51893aeb7419bd67bbbeea82/README.md#L101):
> - Open **Regular**, **Private**, or **Isolated** tabs. Each isolated tab has a separate session from every other tab. Unlike private tabs, isolated tabs remain open after you quit and reopen WebLibre.
