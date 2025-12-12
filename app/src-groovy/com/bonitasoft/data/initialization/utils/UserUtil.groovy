package com.bonitasoft.data.initialization.utils

import org.bonitasoft.engine.identity.ContactData
import org.bonitasoft.engine.identity.User

import com.bonitasoft.engine.api.APIAccessor

trait UserUtil {
	def getEmail(APIAccessor apiAccessor, long userId) {
		ContactData data = apiAccessor.getIdentityAPI().getUserContactData(userId,false)
		data.email
	}

	User getUser(APIAccessor apiAccessor, String username) {
		apiAccessor.getIdentityAPI().getUserByUserName(username)
	}

	User getUserByID(APIAccessor apiAccessor, long userId) {
		apiAccessor.getIdentityAPI().getUser(userId)
	}
}
