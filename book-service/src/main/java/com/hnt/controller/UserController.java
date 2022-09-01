package com.hnt.controller;

import java.util.List;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.hnt.entity.User;
import com.hnt.service.UserService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@CrossOrigin
@RestController // spring bean
@RequestMapping("/api/v1/digitalbooks/")
public class UserController  {// accept requests
	@Autowired // DI
	UserService userService; // dependency

	@GetMapping
	Iterable<User> getUser() {
		return userService.getUser();
	}

	@GetMapping("books/search")
	User getBook(@RequestParam String category,
			@RequestParam String author,
			@RequestParam int price,
			@RequestParam String publisher) {
		Iterable<User> books=  userService.getUser();
		
		for(User b : books) {
			if(b.getCategory().equals(category) &&
					b.getAuthor().equals(author) &&
					b.getPrice()==price &&
					b.getPublisher().equals(publisher)) {
				return b;
			}
		}
		return new User();
	}

	@PostMapping("/author/books")
	Integer saveUser1(@Valid @RequestBody User user) {
		userService.save(user);//mock
		System.out.println("second");
		return user.getId();
	}
}