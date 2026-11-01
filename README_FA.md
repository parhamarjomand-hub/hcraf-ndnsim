# HCRAF — آزمون امکان اجرای ابری ndnSIM با GitHub Actions

**وضعیت: پایلوت آماده اجرا، اما هنوز روی GitHub Actions اجرا و تأیید نشده است.**

این بسته برای پاسخ دادن به یک سؤال ساخته شده است: آیا می‌توان بدون نصب ndnSIM روی لپ‌تاپ، نسخه رسمی ndnSIM را روی سرور ابری GitHub ساخت و خروجی واقعی Trace گرفت؟

## کارهایی که Workflow انجام می‌دهد

1. یک سرور GitHub با `ubuntu-24.04` دریافت می‌کند.
2. داخل آن کانتینر `ubuntu:20.04` اجرا می‌شود (نسخه‌ای که در مستندات ndnSIM برای آن سازگاری گزارش شده است).
3. سورس سه مخزن رسمی `ns-3-dev`، `pybindgen` و `ndnSIM` (همراه submoduleها) را دریافت می‌کند.
4. طبق مستندات ndnSIM، بدون Python bindings و با examples فعال، نرم‌افزار را کامپایل می‌کند.
5. سه مثال رسمی `ndn-simple`، `ndn-tree-tracers` و `ndn-tree-app-delay-tracer` را اجرا می‌کند.
6. فایل‌های واقعی `rate-trace.txt` و `app-delays-trace.txt` را بررسی کرده و با نسخه دقیق کدها و گزارش‌ها در بخش Artifact ذخیره می‌کند.

## اجرای اولیه بدون نصب ndnSIM

1. به https://github.com/new بروید و یک Repository جدید ایجاد کنید.
2. فایل‌های داخل این ZIP را **با حفظ پوشه‌های مخفی `.github/workflows`** در ریشه Repository قرار دهید. ترجیحاً ابتدا از مخزن خصوصی برای کد پژوهشی استفاده کنید؛ اما محدودیت دقیقه و منابع آن را در نظر بگیرید.
3. در مخزن، تب **Actions** را باز کنید و اگر لازم است Actions را فعال کنید.
4. Workflow با نام **HCRAF / ndnSIM cloud compatibility pilot** را باز کنید.
5. روی **Run workflow** کلیک کنید.
6. پس از پایان، رنگ وضعیت را بررسی کنید و در صفحه Run، بخش **Artifacts** را باز کنید.
7. فایل ZIP خروجی `hcraf-ndnsim-cloud-pilot-...` را دانلود کنید و در این گفت‌وگو ارسال کنید (یا لاگ خطا را ارسال کنید).

**نکته:** بارگذاری ZIP مستقیماً به شکل یک فایل ZIP داخل GitHub کافی نیست؛ باید محتویات استخراج‌شده، شامل YAML داخل `.github/workflows/` در Repository قرار بگیرند.

## نشانه موفقیت

وجود موارد زیر در Artifact و `PASS` در `trace_verification.json`:

- `source_versions.txt`: SHA هر مخزن، نسخه کامپایلر و submoduleها؛
- `rate-trace.txt`: فایل واقعی ثبت نرخ بسته از مثال رسمی؛
- `app-delays-trace.txt`: فایل واقعی تأخیر در سطح برنامه از مثال رسمی؛
- `trace_verification.json`: شمار سطرها و نتیجه کنترل اولیه؛
- `build.log` و `run.log`: امکان عیب‌یابی و بررسی مستند.

## مرز اعتبار علمی

این خروجی‌ها **دیتاست HCRAF نیستند** و **Forwarding Episode را ثبت نمی‌کنند**. آن‌ها فقط آزمون راه‌اندازی محیط ابری هستند. پس از تأیید این پایلوت باید سناریوهای HCRAF، کد ثبت PIT Entry × upstream Face، بازفرست‌ها، Outcomeها، پنجره‌های زمانی و Controlled Probing را توسعه دهیم.

## مواردی که هنوز آزمایش نشده‌اند

- سازگاری تمام revisionهای فعلی سه مخزن رسمی روی کانتینر Ubuntu 20.04؛
- مدت واقعی کامپایل و فضای مصرفی؛
- موفقیت build و اجرای واقعی در GitHub Actions؛
- کارایی سناریوهای بزرگ و آزمایش‌های تکراری HCRAF.

اگر کامپایل شکست خورد، به‌جای تولید داده ساختگی، لاگ خطا را بررسی و نسخه‌ها یا بسته‌ها را اصلاح می‌کنیم. در نسخه پژوهشیِ پایدار، بعد از موفقیت اولیه، SHA سورس‌ها را pin می‌کنیم و برای سرعت بیشتر cache / container آماده ساخت در نظر می‌گیریم.

## منابع اولیه

- ndnSIM official getting started: https://ndnsim.net/current/getting-started.html
- Official examples: https://ndnsim.net/current/examples.html
- GitHub Actions job containers: https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/run-jobs-in-a-container
- GitHub-hosted runners: https://docs.github.com/en/actions/reference/runners/github-hosted-runners
