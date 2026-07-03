# Week 5 – Apache Spark (PySpark) Assignment

## 📌 Project Overview

This project demonstrates the use of **Apache Spark (PySpark)** to perform various data processing, transformation, and analytical operations. The assignment covers both theoretical concepts and practical implementations of Spark DataFrame APIs, helping to build a strong understanding of modern big data processing techniques.

The notebook includes examples of data cleaning, filtering, aggregation, schema handling, duplicate removal, null value management, and Spark transformation concepts.

---

## 🎯 Objectives

* Understand the limitations of traditional MapReduce.
* Learn the concept of Spark In-Memory Computing.
* Perform duplicate removal using Spark DataFrames.
* Apply filtering conditions on datasets.
* Use `groupBy()` and aggregation functions.
* Handle null values using `.na.drop()` and `.na.fill()`.
* Understand Spark DataFrame immutability.
* Perform schema transformations and type casting.
* Learn about Shuffle operations and wide transformations.
* Build complete data processing pipelines using PySpark.

---

## 🛠️ Technologies Used

* Python
* Apache Spark (PySpark)
* Google Colab
* Jupyter Notebook

---

## 📚 Topics Covered

* Spark vs MapReduce
* In-Memory Computing
* DataFrame Operations
* Duplicate Removal
* Data Filtering
* Null Value Handling
* Aggregation Functions
* GroupBy Operations
* Data Cleaning Techniques
* Column Renaming
* Data Type Casting
* Timestamp Conversion
* Shuffle Process
* Wide Transformations
* Processing Pipelines

---

## ⚙️ Practical Operations Performed

* Removed duplicate records using `dropDuplicates()`
* Filtered datasets using multiple conditions
* Calculated average, minimum, maximum, and total values using `.agg()`
* Grouped records using `groupBy()`
* Filled missing values using `.na.fill()`
* Removed invalid records using filtering operations
* Converted string columns into `TimestampType`
* Renamed DataFrame columns
* Created complete data cleaning pipelines
* Applied Spark transformation concepts to real-world examples

---

## 📊 Learning Outcomes

After completing this assignment, the following concepts were understood:

* Difference between Spark and traditional MapReduce
* Advantages of In-Memory Computing
* Efficient handling of missing and duplicate data
* Use of DataFrame APIs for filtering and aggregation
* Working with immutable Spark DataFrames
* Schema conversion and timestamp handling
* Understanding Shuffle and wide transformations
* Building optimized data processing workflows in PySpark

---

## 🚀 Conclusion

This assignment provides hands-on experience with Apache Spark and demonstrates how PySpark can be used for efficient big data processing and data cleaning. It highlights best practices for handling real-world datasets while improving performance through distributed computing and in-memory processing.
