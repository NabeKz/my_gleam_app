export default {
  local_time: () => {
    const d = new Date()
    const {
      year
    } = {
      year: d.getFullYear(),
      month: d.getMonth() + 1,
      day: d.getDate(),
      hours: d.getHours(),
      minutes: d.getMinutes(),
      secondes: d.getSeconds(),
    }

    return [[year, month, day], [hours, minutes, secondes]]
  }
}