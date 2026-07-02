# E-Ticaret Dönüşüm Hunisi Analizi

GA4 (Google Analytics 4) BigQuery genel örnek veri kümesi kullanılarak hazırlanmış, uçtan uca bir e-ticaret dönüşüm hunisi analizi ve interaktif gösterge tablosu.

**🔗 Canlı Gösterge Tablosu:** [Looker Studio linkini buraya ekleyin]
**🔗 BigQuery Veri Kaynağı:** [BigQuery tablo linkini buraya ekleyin]

---

## Proje Özeti

Bu proje, bir GA4 e-ticaret sitesindeki kullanıcı davranışını 7 adımlı bir dönüşüm hunisi üzerinden analiz eder:

1. Oturum Başlangıcı (`session_start`)
2. Ürün İncelemesi (`view_item`)
3. Sepete Ekleme (`add_to_cart`)
4. Sipariş Başlatma (`begin_checkout`)
5. Teslimat Bilgisi (`add_shipping_info`)
6. Ödeme Bilgisi (`add_payment_info`)
7. Satın Alma (`purchase`)

## Veri Kaynağı

- **Kaynak:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
- **Tarih Aralığı:** 2020-11-01 – 2021-01-31
- **Kayıt Sayısı:** ~240K oturum

## Teknik Yaklaşım

GA4'ün ham olay tabanlı (event-level) veri yapısı, her satırın bir "event" olduğu ve boyutların `event_params` altında iç içe (nested) `key-value` çiftleri olarak saklandığı bir formattadır. Bu ham veriyi analiz edilebilir hale getirmek için:

1. **Parametre çıkarımı:** `UNNEST` ve `TEMP FUNCTION`lar ile `event_params` içinden `session_id`, `page_location` gibi değerler çekildi.
   > ⚠️ Önemli bulgu: `ga_session_id` parametresi GA4'te `int_value` olarak saklanır, `string_value` olarak **değil**. Bu ayrımı gözden kaçırmak, session ID'lerin sürekli `NULL` gelmesine ve sorgunun sıfır satır döndürmesine yol açıyor.

2. **Oturum bazlı toparlama:** Her `user_pseudo_id` + `session_id` kombinasyonu tekil bir oturum (`session_key`) olarak gruplandı; her oturum için ilk ziyaret edilen sayfa (landing page), cihaz ve trafik kaynağı bilgileri `ARRAY_AGG(... ORDER BY event_ts LIMIT 1)` ile alındı.

3. **Huni bayrakları:** `MAX(IF(event_name = '...', 1, 0))` deseniyle her oturumun hangi huni adımlarına ulaştığı 0/1 bayraklarla işaretlendi.

### Ana SQL Sorgusu (özet)

```sql
WITH raw_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    CAST(get_int_param(event_params, 'ga_session_id') AS STRING) AS session_id_str,
    get_string_param(event_params, 'page_location') AS page_location,
    device.category AS device_category,
    device.language AS device_language,
    device.operating_system AS device_os,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    ecommerce.purchase_revenue AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN (
      'session_start', 'view_item', 'add_to_cart',
      'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase'
    )
)
-- oturum bazlı gruplama ve huni bayrakları ...
```

Tam sorgu dosyası: [`sql/01_ana_sorgu.sql`](sql/01_ana_sorgu.sql)

## Gösterge Tablosu Yapısı

| Bileşen | Açıklama |
|---|---|
| KPI Scorecard'lar | Toplam Oturum, Toplam Sipariş, Toplam Gelir, Dönüşüm Oranı |
| Huni Grafiği | 7 adımlı dönüşüm hunisi, adım bazlı düşüş oranlarıyla |
| Cihaz/İşletim Sistemi Kırılımı | Stacked bar chart |
| Trafik Kaynağı Kırılımı | Bar chart |
| İşletim Sistemi Dağılımı | Pie chart |
| Filtreler | Tarih aralığı, cihaz kategorisi, giriş sayfası, cihaz dili, trafik kaynağı/mecra/kampanya, işletim sistemi |

## Öne Çıkan Bulgular

- **Oturum → Ürün İncelemesi:** %21,7
- **Oturum → Sepete Ekleme:** %4,28 (huninin en büyük kaybının yaşandığı adım)
- **Oturum → Satın Alma (genel dönüşüm oranı):** ~%1,4

## Kullanılan Araçlar

- **BigQuery** — veri işleme ve SQL sorguları
- **Looker Studio** — interaktif gösterge tablosu
- **GA4 Event Schema** — veri modeli referansı

## Karşılaşılan Zorluklar ve Çözümler

| Sorun | Kök Neden | Çözüm |
|---|---|---|
| Ana sorgu 0 satır döndürdü | `ga_session_id` yanlış tipte (`string_value` yerine `int_value`) okunuyordu | `get_int_param` ile düzeltildi, `CAST(... AS STRING)` uygulandı |
| Huni grafiğinde tek metrik seçilebiliyordu | Ana tablo "geniş format"ta (her adım ayrı sütun); Looker Studio huni grafiği "uzun format" (tek dimension + tek metric) bekliyor | Ayrı bir özet sorgu (`step`, `sessions` sütunlu) yazılıp huni grafiği bu kaynağa bağlandı |
| Filtre dropdown'ları alan adını (`device_category` vb.) gösteriyordu | Görüntülenen ad, BigQuery sütun adıyla birebir eşleşiyordu | Veri kaynağında alan adları Türkçeleştirildi (`Cihaz Kategorisi` vb.) |

## Klasör Yapısı

```
├── README.md
├── sql/
│   ├── 01_ana_sorgu.sql
│   ├── 02_huni_ozeti.sql
│   ├── 03_kpi.sql
│   ├── 04_gunluk_trend.sql
│   └── 05_kesit_kirilimlari.sql
└── screenshots/
    └── dashboard_overview.png
```
