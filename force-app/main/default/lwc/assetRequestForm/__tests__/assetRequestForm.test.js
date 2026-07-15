import { createElement } from '@lwc/engine-dom';
import AssetRequestForm from 'c/assetRequestForm';
import requestAsset from '@salesforce/apex/AssetController.requestAsset';

jest.mock('@salesforce/apex/AssetController.requestAsset', () => ({
    __esModule: true,
    default: jest.fn()
}));

describe('c-asset-request-form', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('dispatches a success event after a successful submit', async () => {
        requestAsset.mockResolvedValue('REQ-001');

        const element = createElement('c-asset-request-form', {
            is: AssetRequestForm
        });

        const successHandler = jest.fn();
        element.addEventListener('requestsuccess', successHandler);
        element.assetRequest = {
            employeeId: 'emp-1',
            assetId: 'asset-1',
            priority: 'High',
            reason: 'Need the equipment'
        };

        document.body.appendChild(element);
        await element.handleSubmit();

        expect(requestAsset).toHaveBeenCalledWith({
            assetRequest: element.assetRequest
        });
        expect(successHandler).toHaveBeenCalledTimes(1);
    });
});