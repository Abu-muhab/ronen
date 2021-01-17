const functions = require('firebase-functions')
const { default: algoliasearch } = require('algoliasearch')

const ALGOLIA_APP_ID = 'Y5XKKGNTJ9'
const ALGOLIA_API_KEY = 'da433f357f2d77d014dc4b4e6388b691'

const algolia = algoliasearch(
    ALGOLIA_APP_ID,
    ALGOLIA_API_KEY
)

const index = algolia.initIndex('games')

exports.createGameIndex = functions.firestore.document('games/{docId}').onCreate((change, context) => {
    const childKey = change.id
    const childData = {
        name: change.data().name,
        description: change.data().description
    }
    childData.objectID = childKey

    return index.saveObject(childData).then(() => {
        console.log('Game saved to Algolia')
    }).catch(err => {
        console.error('Error saving game into Algolia', err)
    })
})

exports.updateGameIndex = functions.firestore.document('games/{docId}').onUpdate((change, context) => {
    if (change.before.data().name === change.after.data().name && change.before.data().description === change.after.data().description) {
        return ''
    }
    const childKey = change.after.id
    const childData = {
        name: change.after.data().name,
        description: change.after.data().description
    }
    childData.objectID = childKey

    return index.saveObject(childData).then(() => {
        console.log('Game updated to Algolia')
    }).catch(err => {
        console.error('Error updating game into Algolia', err)
    })
})

exports.deleteGameIndex = functions.firestore.document('games/{docId}').onDelete((change, context) => {
    const childKey = change.id
    return index.deleteObject(childKey).then(() => {
        console.log('Game deleted form Algolia')
    }).catch(err => {
        console.error('Error deleting game form Algolia', err)
    })
})
