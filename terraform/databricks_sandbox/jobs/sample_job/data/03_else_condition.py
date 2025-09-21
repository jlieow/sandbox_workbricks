# Databricks notebook source
_day = dbutils.jobs.taskValues.get("01_set_day", "input_day")
print (_day)