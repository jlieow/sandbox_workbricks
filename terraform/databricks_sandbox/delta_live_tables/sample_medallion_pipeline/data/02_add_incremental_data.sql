-- Databricks notebook source
-- Add some data incrementally in ORDERS 
-- Run pipeline after incremental load
INSERT INTO _jlieow_dev.bronze.orders_raw
SELECT * FROM samples.tpch.orders
LIMIT 10000;