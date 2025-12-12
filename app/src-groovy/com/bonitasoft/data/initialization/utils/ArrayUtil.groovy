package com.bonitasoft.data.initialization.utils

import com.github.javafaker.Faker

trait ArrayUtil {
	def randomInArray(def array) {
		Faker faker = new Faker()
		array [ faker.random().nextInt(0,array.size() - 1) ]
	}
}