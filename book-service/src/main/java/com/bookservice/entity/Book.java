package com.bookservice.entity;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;


@Entity
@Table(	name = "books", 
uniqueConstraints = { 
	@UniqueConstraint(columnNames = "id")
})
public class Book {//not a spring bean
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	private Long authorid;
	public Long getAuthorid() {
		return authorid;
	}
	public void setAuthorid(Long authorid) {
		this.authorid = authorid;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long i) {
		this.id = i;
	}
	@NotBlank(message = "Title cannot be blank#######")
	private String title;
	@NotBlank(message = "Category cannot be blank#######")
	private String category;
	@Min(value = 1, message = "price cannot be less than 1")
	private int price;
	
	private String author;
	@NotBlank(message = "Publisher cannot be blank#######")
	private String publisher;
	@NotBlank(message = "Publisher cannot be blank#######")
	private String publisheddate;
	@Min(value = 1, message = "age cannot be less than 1")
	private int chapters;
	private boolean active;
	
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public int getPrice() {
		return price;
	}
	public void setPrice(int price) {
		this.price = price;
	}
	public String getAuthor() {
		return author;
	}
	public void setAuthor(String author) {
		this.author = author;
	}
	public String getPublisher() {
		return publisher;
	}
	public void setPublisher(String publisher) {
		this.publisher = publisher;
	}
	public String getPublisheddate() {
		return publisheddate;
	}
	public void setPublisheddate(String publisheddate) {
		this.publisheddate = publisheddate;
	}
	public int getChapters() {
		return chapters;
	}
	public void setChapters(int chapters) {
		this.chapters = chapters;
	}
	public boolean isActive() {
		return active;
	}
	public void setActive(boolean active) {
		this.active = active;
	}
	
}