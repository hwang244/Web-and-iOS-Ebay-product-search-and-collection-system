const express = require('express');
const axios = require('axios');
const OAuthToken = require('./ebay_oauth_token');
const cors = require('cors');
const { MongoClient } = require('mongodb');
const ObjectId = require('mongodb').ObjectId;

const PORT = 8080;
const APPID = 'HaoyuWan-dummy-PRD-894557f6d-8bf34bbd';
const client_secret = 'PRD-94557f6d7523-1ed5-4eb4-96cb-aecc';
const connect_str = 'mongodb+srv://hwang244:Wanghaoy1234@frnkcsci571hw3.teqvum0.mongodb.net/?retryWrites=true&w=majority';

const google_key = "AIzaSyAFhwdoWHbRAeDHHbaPafSlyquC78_1_uQ"

const oauthToken = new OAuthToken(APPID, client_secret);
const client = new MongoClient(connect_str);
const app = express();
app.use(cors());
app.use(express.json());

// Open the connection to the database before starting the server
async function connectToMongo() {
    try {
        // Connect to the MongoDB client
        await client.connect();
        console.log('Connected to MongoDB');
    } catch (error) {
        console.error('Could not connect to MongoDB', error);
        process.exit(1); // Exit the process with an error code
    }
}

// Connect to MongoDB when the server starts
connectToMongo().catch(console.error);

async function getIsFavorite(productId) {
    try {
        await client.connect();
        const db = client.db('frnkcsci571hw3');
        const favorites = db.collection('favorites');
        const product = await favorites.findOne({ productId: productId });
        const isFavorite = product != null;
        return isFavorite;
    } catch (error) {
        return null;
    } finally {
        await client.close();
    }
}
function processItems(items) {
    return items.map(item => {
        // Extract only necessary information
        const itemShipping = item.shippingInfo?.[0];
        let shipping;
        let currentPrice;
        let condition;
        if (item.sellingStatus?.[0]?.currentPrice?.[0]?.__value__) {
            const price = parseFloat(item.sellingStatus?.[0]?.currentPrice?.[0]?.__value__);
            if (!isNaN(price)) {
                currentPrice = '$' + price.toFixed(2);
            }
        }
        if (itemShipping?.shippingType?.[0] == 'Free') {
            shipping = "Free Shipping";
        } else if (itemShipping?.shippingType?.[0] == 'FreePickup') {
            shipping = "Free Pickup";
        } else {
            const shippingValue = parseFloat(itemShipping?.shippingServiceCost?.[0]?.__value__);
            if (!isNaN(shippingValue)) {
                if (shippingValue !== 0.0) {
                    shipping = '$' + shippingValue.toFixed(2);
                } else {
                    shipping = itemShipping.shippingType[0];
                }
            } else {
                shipping = itemShipping?.shippingType?.[0];
            }
        }
        // const isFavoriteItem = getIsFavorite(item.itemId[0]);
        return {
            itemId: item.itemId[0],
            image: item.galleryURL[0],
            title: item.title[0],
            price: currentPrice,
            shipping: shipping,
            zipcode: item.postalCode[0],
            shippingInfo: itemShipping,
            returnsAccepted: item?.returnsAccepted[0],
            // isFavoriteItem: isFavoriteItem
            condition: item?.condition
        };
    });
};


function processItemDetail(itemData) {
    const item = itemData;
    const itemId = item?.ItemID;
    const pic = item?.PictureURL;
    const priceValue = parseFloat(item?.CurrentPrice?.Value);
    const price = priceValue ? '$' + priceValue.toFixed(2) : 'N/A';
    const location = item?.Location;
    const detailValues = item?.ItemSpecifics?.NameValueList;
    let returnPolicy = 'Not specified';
    if (item?.ReturnPolicy) {
        if (item.ReturnPolicy.ReturnsWithin && item.ReturnPolicy.ReturnsWithin !== '0 Days') {
            returnPolicy = item.ReturnPolicy.ReturnsAccepted + ' Within ' + item.ReturnPolicy.ReturnsWithin;
        } else {
            returnPolicy = item.ReturnPolicy.ReturnsAccepted;
        }
    }
    detailResults = {
        ItemId: itemId,
        PicUrl: pic,
        Price: price,
        Location: location,
        ReturnPolicy: returnPolicy
    }
    if (Array.isArray(detailValues)) {
        detailValues.forEach((detail) => {
            detailResults[detail?.Name] = detail?.Value?.[0] || 'N/A'; // Using 'N/A' if Value is not available
        });
    }
    return detailResults;
}

app.get('/', (req, res) => {
    res.send("Csci571 hwang244 Node.js Server Deployed!");
});

app.get('/search', (req, res) => {
    let keyword = req.query.keyword;
    let zipcode = req.query.zipcode;
    let distance = req.query.distance;
    let conditions = JSON.parse(req.query.conditions);
    let shippings = JSON.parse(req.query.shippings);
    let freeShipping = shippings.includes("Free Shipping");
    let pickUp = shippings.includes("Local Pickup");
    url = `https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.0.0` +
        `&SECURITY-APPNAME=HaoyuWan-dummy-PRD-894557f6d-8bf34bbd&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=50` +
        `&keywords=${keyword}&buyerPostalCode=${zipcode}&itemFilter(0).name=MaxDistance&itemFilter(0).value=${distance}&itemFilter(1).name=FreeShippingOnly&itemFilter(1).value=${freeShipping}` +
        `&itemFilter(2).name=LocalPickupOnly&itemFilter(2).value=${pickUp}&itemFilter(3).name=HideDuplicateItems&itemFilter(3).value=true&itemFilter(4).name=Condition`;
    for (let i = 0; i < conditions.length; i++) {
        console.log(conditions[i]);
        url = url + `&itemFilter(4).value(${i})=${conditions[i]}`;
    }
    url = url + `&outputSelector(0)=SellerInfo&outputSelector(1)=StoreInfo`;
    console.log(url);
    axios.get(url)
        .then(function (response) {
            if ("data" in response) {
                const results = response.data.findItemsAdvancedResponse[0].searchResult[0];
                if (results.item) {
                    const processedItems = processItems(results.item);
                    res.send(processedItems);
                } else {
                    res.send(null);
                }
            } else {
                res.status(404).send({ message: "No items found in the search results." });
            }
        })
        .catch(function (error) {
            console.error('Error submitting data:', error);
    });
});

app.get('/detail/product', async (req, res) => {
    const itemId = req.query.itemId;
    if (!itemId) {
        return res.status(400).send('Item ID is required');
    }
    const url = `https://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=${APPID}&siteid=0&version=967&ItemID=${itemId}&IncludeSelector=Description,Details,ItemSpecifics`;

    try {
        const token = await oauthToken.getApplicationToken();
        const config = {
            headers: {
                'X-EBAY-API-IAF-TOKEN': token
            }
        };
        const response = await axios.get(url, config);
        if (response.data.Ack !== 'Success') {
            throw new Error(response.data.Errors?.[0]?.ShortMessage || 'Error fetching data from eBay');
        }
        if (response.data.Item) {
            const itemData = response.data.Item;
            const itemDetails = processItemDetail(itemData);
            res.send(itemData);
        }
    } catch (error) {
        console.error('Error fetching details:', error);
        res.status(500).send(error.response?.data || error.message);
    }
});

app.post('/addToFavorites', async (req, res) => {
    try {
        const db = client.db('frnkcsci571hw3');
        const favorites = db.collection('favorites');
        await favorites.insertOne({
            productId: req.body.productId,
            image: req.body.image,
            title: req.body.title,
            price: req.body.price,
            shipping: req.body.shipping,
            zipcode: req.body.zipcode,
            condition: req.body.condition
        });
        res.status(200).send({ message: 'Added to favorites' });
    } catch (error) {
        console.error('Error adding to favorites:', error); // This will log the error object to the console
        res.status(500).send({ message: 'Error adding to favorites', error: error.message });
    }
});

app.post('/removeFromFavorites', async (req, res) => {
    try {
        const db = client.db('frnkcsci571hw3');
        const favorites = db.collection('favorites');

        // Remove the item from the favorites collection based on productId
        const result = await favorites.deleteMany({ productId: req.body.productId });
        res.status(200).send({ message: 'Removed from favorites' });
    } catch (error) {
        res.status(500).send({ message: 'Error removing from favorites', error });
    }
});

app.get('/isFavorite', async (req, res) => {
    try {
        const db = client.db('frnkcsci571hw3');
        const favorites = db.collection('favorites');
        const productId = req.query.productId;
        const product = await favorites.findOne({ productId: productId });
        const isFavorite = product != null;
        console.log(productId, isFavorite);
        res.status(200).send({ isFavorite });
    } catch (error) {
        console.error('Error checking favorite status:', error);
        res.status(500).send({ message: 'Error checking favorite status', error });
    }
});


// Express route handler
app.get('/favorites', async (req, res) => {
    try {
        const db = client.db('frnkcsci571hw3');
        const favorites = db.collection('favorites');
        const allFavorites = await favorites.find({}).toArray();
        res.status(200).json(allFavorites);
    } catch (error) {
        console.error('Error retrieving favorites:', error);
        res.status(500).send({ message: 'Error retrieving favorites', error: error.message });
    }
    // Do not close the client here
});

app.get('/areFavorites', async (req, res) => {
    try {
        const db = client.db('frnkcsci571hw3');
        const favorites = db.collection('favorites');
        const productIds = req.query.productIds.split(',');
        const productsInFavorites = await favorites.find({ productId: { $in: productIds } }).toArray();

        // This map will create an array of booleans where each boolean indicates 
        // whether the productId is found in the productsInFavorites array.
        const isFavorites = productIds.map(productId =>
            productsInFavorites.some(favoriteProduct => favoriteProduct.productId === productId));
        console.log(productIds);
        console.log(isFavorites);
        res.send(isFavorites);
    } catch (error) {
        res.status(500).send({ message: 'Error checking favorite statuses', error });
    }
});

app.get('/pictures', async (req, res) => {
    try{
        const title = req.query.title;
        if (!title) {
            return res.status(400).send('Item title is required');
        }
        const url = `https://www.googleapis.com/customsearch/v1?q=${title}&cx=e3661f63ffe3e4563&imgSi\
        ze=huge&imgType=photo&num=8&searchType=image&key=${google_key}`;
        const response = await axios.get(url);
        if (!response.data.items) {
            throw new Error('No items found');
        }

        // Extract links from items
        const links = response.data.items.map(item => item.link);

        // Send links as response
        res.send(links);
    }catch(error){
        res.status(500).send({ message: 'Error getting Google Custom pictures', error });
    }
});
app.get('/autozip', async(req, res)=>{
    try{
        const zip_input = req.query.zip;
        if(!zip_input){
            return res.status(400).send('zip input is required!');
        }
        const url = `http://api.geonames.org/postalCodeSearchJSON?postalcode_startsWith=${zip_input}&maxRows=5&username=frnk9927&country=US`;
        const response = await axios.get(url)
        const postalCodes = response.data.postalCodes.map(code => code.postalCode)
        res.json({postalCodes})
    }catch(error){
        res.status(500).send({ message: 'Error autocomplete zipcodes', error });
    }
});
// Handle server shutdown
process.on('SIGINT', async () => {
    try {
        console.log('Closing MongoDB connection');
        await client.close();
        console.log('MongoDB connection closed');
        process.exit(0);
    } catch (error) {
        console.error('Failed to close MongoDB connection', error);
        process.exit(1);
    }
});
app.listen(PORT, () => {
    console.log(`Server is running on Port ${PORT}`);
});
