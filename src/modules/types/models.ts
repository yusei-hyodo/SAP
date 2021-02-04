import firebase from 'firebase/app'

// *******************
// db
// *******************

// common

interface Base {
  uid?: string
  createdAt?: firebase.firestore.Timestamp
  updatedAt?: firebase.firestore.Timestamp
}

// *******************
// /users
export enum Gender {
  MALE = 1,
  FEMALE = 2,
  OTHER = 3,
}
export interface User extends Base {
  email: string
  nickname: string
}

// *******************
// /apps
export interface App extends Base {
  userUid: string
  name: string
  description: string
  startAt: firebase.firestore.Timestamp
  votingEndAt: firebase.firestore.Timestamp
  browsingEndAt: firebase.firestore.Timestamp
}

// *******************
// /apps/group
export interface Group extends Base {
  name: string
  description: string
}

// ****************************
// /apps/chats
export interface Chat extends Base {
  userUid: string
  content: string
}

// ****************************
// /apps/participateUsers
// uidはuserUid
export interface ParticipateUser extends Base {
  groupUid: string
  hopeUserUidItems: string[]
}