# **E-Commerce Funnel & Conversion Analysis using SQL**

E-commerce teams often have plenty of raw event data but no clear view of where the purchase funnel is leaking users or which channels are worth the marketing spend. This project analyzes one such user-level e-commerce event data to answer three questions:

1. Where in the funnel are the biggest drop-offs, and how much revenue does that represent?  
2. Which acquisition channels convert best?  
3. How long does it typically take a converting user to move from first view to purchase?

## **Tools Used**

* SQL (BigQuery Standard SQL)

## **Data**

* **Source:** `user_events` table, BigQuery (`marketing-analysis-501508.sql_practice.user_events`)  
* **Grain:** one row per user event  
* **Columns:** `event_id`, `user_id`, `event_type`, `event_date`, `product_id`, `amount`, `traffic_source`  
* **Volume:** 9,381 rows spanning 35 days  
* **Event types:** `page_view` → `add_to_cart` → `checkout_start` → `payment_info` → `purchase`

## **Data Quality Checks**

Before trusting any conversion numbers, I validated the dataset for the issues that would most distort a funnel analysis: duplicate events, nulls in key fields, inconsistent category labels, and date range reliability. The dataset passed all checks , no duplicate events, no nulls in any critical field, a consistent 35-day date range, and no inconsistent labeling across event types or traffic sources. Validation queries are in `data_quality_checks.sql`.

## **Analysis**

All queries are in `funnel_analysis.sql`, run over a trailing 30-day window.

### **1\. Funnel volume and drop-off by stage**

| Stage | Users | Stage-to-Stage Conversion |
| :---: | :---: | :---: |
| Page View | 4,268 | — |
| Add to Cart | 1,332 | 31.2% |
| Checkout | 951 | 71.4% |
| Payment | 768 | 80.8% |
| Purchase | 708 | 80.8% |
| **Overall (View → Purchase)** | — | **16.6%** |

**Finding:** Out of every 100 people who view a product, only about 17 end up buying. The biggest drop happens right at the start of the funnel between Page View and Add to Cart, only 31.2% of viewers add anything to their cart at all. That means roughly 7 out of 10 visitors leave before ever showing purchase intent. But as someone reaches checkout, the remaining steps hold up well , about 81% of people who start checkout go on to pay, and 81% of people who enter payment details go on to complete the purchase. In other words, the funnel isn't losing people at the finish line, it's losing them at the very first step.

### **2\. Channel effectiveness**

| Traffic Source | Views | Cart | View→Cart Rate | Cart→Purchase Rate | Purchases | View→Purchase Rate |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Email | 445 | 280 | 62.9% | 53.9% | 151 | 33.9% |
| Paid Ads | 820 | 305 | 37.2% | 56.7% | 173 | 21.1% |
| Organic | 1,750 | 576 | 32.9% | 52.1% | 300 | 17.1% |
| Social | 1,253 | 171 | 13.6% | 49.1% | 84 | 6.7% |

**Finding:** Email is by far the most efficient channel as it brings in the fewest visitors of any channel (445), but converts them into buyers at more than double the rate of every other channel (33.9%). Social performs the worst as it brings in the second-highest volume of visitors (1,253) but converts the worst by a wide margin (6.7%), meaning most social visitors never buy. Organic drives the most raw traffic (1,750) and performs overall averagely (17.1%), while Paid Ads sits in the middle on both volume and conversion.

### **3\. Time to conversion**

* Average time from view to cart: 11.19 minutes  
* Average time from cart to purchase: 13.36 minutes  
* Average total journey (view to purchase): 24.55 minutes  
* Total converted users: 708

**Finding:** Users who buy tend to do so quickly .On average, less than 25 minutes pass between someone first viewing a product and completing a purchase. This points to a relatively impulse-driven buying pattern or shows that a pattern of decisive customers who already know what to buy when they visit the store/site rather than a slow, considered decision.

### **4\. Revenue impact**

* Total revenue (30 days): $76,037.90  
* Average order value (AOV): $107.40  
* Revenue per buyer: $107.40  
* Revenue per visitor: $17.82

**Finding:** Each visitor who lands on the site is worth about $17.82 on average, but each person who actually buys is worth about $107.40. That gap is almost entirely explained by the funnel drop-off identified above and since the biggest leak happens between Page View and Add to Cart, improving that single step would inturn have a positive effect on total revenue too.

## **Key Takeaways**

* The funnel's biggest problem isn't checkout, it's the very top and the start .Fewer than a third of visitors ever add something to their cart, therefore fixing that one step would increase total revenue more than any other change.  
* Email is the most efficient acquisition channel by a wide margin.While social medias drive real heavy traffic , it converts poorly, and therefore is also worth reviewing as a purchase-driving channel. This once again also points that work is needed for the top of the funnel .  
* Buyers who convert do so quickly (under 25 minutes on average). This could mean either the customers are decisive and visit the site with the intention of buying or that the website’s user flow is seamless. 

## **Recommendations to the business**

1. **Focus on the top of the funnel :** The data shows checkout and payment already convert well (around 81% at each step), so redesigning/focusing on that part of the site carries more risk right now. The real focus should be figuring out why only 31% of viewers add a product to their cart in the first place ,that could mean anything from product page content, pricing visibility, image quality, or a missing sense of urgency.  
2. **Lean into email, and look into social’s role :** Email converts visitors into buyers at more than double the rate of any other channel. Rather than assuming social is "worse," it's worth treating social as a channel for building awareness and growing the email list, rather than expecting it to drive direct purchases the way email currently does.  
3. **Notifying the customers early :** Since converting users complete their entire journey in under 25 minutes on average, cart-abandonment emails or reminders sent a day later are likely arriving too late to matter. A same-session or same-hour notification/reminder would better match how the users are actually behaving.

## **Files**

| File | Description |
| ----- | ----- |
| [`data_quality_checks.sql`](https://github.com/grgdeepsa-web/Funnel_analysis_project/blob/main/data_quality_checks.sql)| Validation queries run before exploration and analysis |
| [`funnel_analysis.sql`](https://github.com/grgdeepsa-web/Funnel_analysis_project/blob/main/funnel_analysis.sql) | Funnel, channel, time-to-convert, and revenue queries |
| [`README.md`](https://github.com/grgdeepsa-web/Funnel_analysis_project/edit/main/README.md#e-commerce-funnel--conversion-analysis-using-sql)| Detailed explanation of the project, what was discovered from the dataset, and recommended next steps |

### 
