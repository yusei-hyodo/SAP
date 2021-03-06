<template lang="pug">
  v-container(style="max-width:1000px")
    template(v-if="roomUid")
      BtnPageBack(:link="$routes.front.roomDashboard(roomUid)")

      BaseVComponent(:title="`「${title}」部屋の編集`" icon="mdi-monitor-dashboard")

      client-only
        RoomForm(
          submitText="編集する"
          :roomUidValue.sync="roomUid"
          :imgDataURLValue.sync="imgDataURL"
          :nameValue.sync="name"
          :descriptionValue.sync="description"
          :isPublicValue.sync="isPublic"
          :groupDisplayNameValue.sync="groupDisplayName"
          :groupIsEditValue.sync="groupIsEdit"
          :groupHopeMaxNumValue.sync="groupHopeMaxNum"
          :participateUserDisplayNameValue.sync="participateUserDisplayName"
          :participateUserIsEditValue.sync="participateUserIsEdit"
          :participateUserHopeMaxNumValue.sync="participateUserHopeMaxNum"
          :startAtValue.sync="startAt"
          :votingEndAtValue.sync="votingEndAt"
          :browsingEndAtValue.sync="browsingEndAt"
          :submitFunc="submit"
        )

      .my-4.text-center
        v-btn(color="error" text @click="removeDialog = true") 削除する

        v-dialog(
          v-model="removeDialog"
          max-width="400"
          persistent
        )
          v-card
            v-card-title 本当に削除しますか？
            v-card-actions
              v-btn(
                text
                :disabled="isRemoveLoading"
                @click="removeDialog = false"
              ) いいえ
              v-spacer
              v-btn(
                color="error"
                elevation="0"
                :disabled="isRemoveLoading"
                :loading="isRemoveLoading"
                @click="remove"
              ) はい
  
    v-overlay(v-else)
      v-progress-circular(indeterminate size="64")
</template>

<script lang="ts">
import { Component, Vue } from 'nuxt-property-decorator'
import { Room } from '~/modules/types/models'

@Component({
  layout: 'protected',
  components: {
    BaseVComponent: () => import('~/components/base/BaseVComponent.vue'),
    BtnPageBack: () => import('~/components/btn/PageBack.vue'),
    RoomForm: () => import('~/components/pages/rooms/Form.vue'),
  },
})
export default class RoomNewPage extends Vue {
  async beforeMount() {
    try {
      const { uid } = this.$route.params
      const item = await this.$fire.store.room.getItem(uid)
      if (item === null) throw Error
      this.setItem(item)
    } catch {
      this.$nuxt.error({
        statusCode: 404,
        message: 'ページが見つかりませんでした。',
      })
    }
  }

  setItem(item: Room) {
    this.title = item.name
    this.roomUid = item.uid as string
    this.iconPath = item.iconPath
    this.name = item.name
    this.description = item.description
    this.isPublic = item.isPublic
    this.groupDisplayName = item.groupDisplayName
    this.groupIsEdit = item.groupIsEdit
    this.groupHopeMaxNum = item.groupHopeMaxNum
    this.participateUserDisplayName = item.participateUserDisplayName
    this.participateUserIsEdit = item.participateUserIsEdit
    this.participateUserHopeMaxNum = item.participateUserHopeMaxNum
    this.startAt = item.startAt.toDate()
    this.votingEndAt = item.votingEndAt.toDate()
    this.browsingEndAt = item.browsingEndAt.toDate()

    if (this.iconPath) this.getImgDataURLToUrl(this.iconPath)
  }

  async getImgDataURLToUrl(filePath: string) {
    const downloadUrl = await this.$fire.storage.getDownloadURL(filePath)
    const res = await this.$axios.get(downloadUrl, { responseType: 'blob' })
    const reader = new FileReader()
    reader.onload = (e: any) => {
      const imgDataURL = e.target.result as string
      this.imgDataURL = imgDataURL
    }
    reader.readAsDataURL(res.data)
  }

  title = ''

  // form var

  roomUid = ''
  iconPath = ''
  name = ''
  description = ''
  isPublic = false

  // group
  groupDisplayName: string | null = null
  groupIsEdit: boolean
  groupHopeMaxNum: number | null = null

  // participate user
  participateUserDisplayName: string | null = null
  participateUserIsEdit: boolean
  participateUserHopeMaxNum: number | null = null

  // time
  startAt = new Date()
  votingEndAt = new Date()
  browsingEndAt = new Date()
  imgDataURL = ''

  async submit(): Promise<void> {
    // ファイルパスを取得
    let iconPath = ''
    if (this.imgDataURL) {
      iconPath = `rooms/${this.roomUid}.jpg`
    }

    try {
      // 画像をアップロード
      if (iconPath) {
        await this.$fire.storage.uploadToDataURL(iconPath, this.imgDataURL)
      }

      // firestoreに保存
      const item: Room = {
        userUid: this.$store.state.user.uid,
        iconPath,
        name: this.name,
        description: this.description,
        isPublic: this.isPublic,
        groupDisplayName: this.groupDisplayName || null,
        groupIsEdit: this.groupIsEdit || false,
        groupHopeMaxNum: this.groupHopeMaxNum || null,
        participateUserDisplayName: this.participateUserDisplayName || null,
        participateUserIsEdit: this.participateUserIsEdit || false,
        participateUserHopeMaxNum: this.participateUserHopeMaxNum || null,
        startAt: this.$fire.store.convertTimestamp(this.startAt),
        votingEndAt: this.$fire.store.convertTimestamp(this.votingEndAt),
        browsingEndAt: this.$fire.store.convertTimestamp(this.browsingEndAt),
      }
      const headers = await this.$fire.auth.getAuthHeaders()
      await this.$api.back.updateRoom({ roomUid: this.roomUid, roomItem: item }, headers)
      this.$store.dispatch('snackbar/success', '部屋を編集しました。')
      this.$router.push(this.$routes.front.roomDashboard(this.roomUid))
    } catch {
      if (iconPath) {
        this.$fire.storage.delete(iconPath)
      }
      this.$store.dispatch('snackbar/error', '部屋の編集に失敗しました。')
      throw Error
    }
  }

  // 削除

  removeDialog = false
  isRemoveLoading = false

  async remove() {
    try {
      this.isRemoveLoading = true
      const roomUid = this.$route.params.uid
      const headers = await this.$fire.auth.getAuthHeaders()
      await this.$api.back.deleteRoom({ roomUid }, headers)
      await this.$store.dispatch('room/init')
      this.$router.push(this.$routes.front.rooms)
      this.$store.dispatch('snackbar/success', `「${this.name}」部屋を削除しました。`)
    } catch {
      this.$store.dispatch('snackbar/error', `「${this.name}」部屋の削除に失敗しました。`)
      this.isRemoveLoading = false
    }
  }
}
</script>
