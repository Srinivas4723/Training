package com.hnt.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.hnt.UserRepository;
import com.hnt.entity.User;
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
	@InjectMocks UserService service;
	@Mock UserRepository repository;
	@Test
	void testSave() {
		User user=new User();
		user.setId(1);
		user.setTitle("Harry");
		user.setCategory("comics");
		user.setAuthor("Sara");
		user.setPrice(500);
		user.setChapters(5);
		user.setPublisher("red books");
		user.setPublisheddate("27/08/1997");
		user.setActive(true);
		
		
		when(repository.save(user)).thenReturn(user);
		//user.setName("Ram");
		service.save(user);
		assertEquals(1,user.getId());
		assertEquals("Harry",user.getTitle());
		assertEquals("comics",user.getCategory());
		assertEquals("Sara",user.getAuthor());
		assertEquals(5,user.getChapters());
		assertEquals(500,user.getPrice());
		assertEquals("red books",user.getPublisher());
		assertEquals("27/08/1997",user.getPublisheddate());
		assertEquals(true,user.isActive());
		
	}

}
